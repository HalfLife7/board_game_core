# frozen_string_literal: true

RSpec.describe BoardGameCore::Game do
  let(:alice) { BoardGameCore::Player.new(id: "p1", name: "Alice") }
  let(:bob) { BoardGameCore::Player.new(id: "p2", name: "Bob") }
  let(:game) { described_class.new(id: "test_game") }

  describe "#initialize" do
    it "sets the game ID" do
      expect(game.id).to eq("test_game")
    end

    it "initializes in waiting state" do
      expect(game.state).to eq(:waiting)
    end

    it "accepts players" do
      game = described_class.new(id: "test_game", players: [alice, bob])
      expect(game.players).to eq([alice, bob])
    end

    it "accepts metadata" do
      metadata = { max_score: 100 }
      game = described_class.new(id: "test_game", metadata: metadata)
      expect(game.metadata).to eq(metadata)
    end
  end

  describe "#start!" do
    context "when there are enough players" do
      before do
        game.add_player(alice)
        game.add_player(bob)
      end

      it "changes state to playing" do
        game.start!
        expect(game.state).to eq(:playing)
      end
    end

    context "when there are not enough players" do
      it "raises an error" do
        expect do
          game.start!
        end.to raise_error(BoardGameCore::Error, "Not enough players to start game")
      end
    end
  end

  describe "#end!" do
    it "changes state to finished" do
      game.end!
      expect(game.state).to eq(:finished)
    end
  end

  describe "#current_player" do
    context "when game is not playing" do
      it "returns nil" do
        expect(game.current_player).to be_nil
      end
    end

    context "when game is playing" do
      before do
        game.add_player(alice)
        game.add_player(bob)
        game.start!
      end

      it "returns the current player" do
        expect(game.current_player).to eq(alice)
      end
    end
  end

  describe "#next_turn!" do
    context "when game is not playing" do
      it "returns false" do
        expect(game.next_turn!).to be false
      end
    end

    context "when game is playing" do
      before do
        game.add_player(alice)
        game.add_player(bob)
        game.start!
      end

      it "returns true" do
        expect(game.next_turn!).to be true
      end

      it "advances to next player" do
        game.next_turn!
        expect(game.current_player).to eq(bob)
      end
    end
  end

  describe "#add_player" do
    context "when game is waiting" do
      it "returns true" do
        expect(game.add_player(alice)).to be true
      end

      it "adds the player" do
        game.add_player(alice)
        expect(game.players).to include(alice)
      end
    end

    context "when game is playing" do
      before do
        game.add_player(alice)
        game.add_player(bob)
        game.start!
      end

      it "returns false" do
        charlie = BoardGameCore::Player.new(id: "p3", name: "Charlie")
        expect(game.add_player(charlie)).to be false
      end
    end

    context "when game is finished" do
      before do
        game.end!
      end

      it "returns false" do
        expect(game.add_player(alice)).to be false
      end
    end
  end

  describe "#remove_player" do
    context "when game is waiting" do
      before do
        game.add_player(alice)
      end

      it "returns true" do
        expect(game.remove_player(alice)).to be true
      end

      it "removes the player" do
        game.remove_player(alice)
        expect(game.players).not_to include(alice)
      end
    end

    context "when game is playing" do
      before do
        game.add_player(alice)
        game.add_player(bob)
        game.start!
      end

      it "returns false" do
        expect(game.remove_player(alice)).to be false
      end
    end
  end

  describe "state predicates" do
    it "correctly identifies waiting state" do
      expect(game.waiting?).to be true
      expect(game.playing?).to be false
      expect(game.finished?).to be false
    end

    it "correctly identifies playing state" do
      game.add_player(alice)
      game.add_player(bob)
      game.start!
      expect(game.waiting?).to be false
      expect(game.playing?).to be true
      expect(game.finished?).to be false
    end

    it "correctly identifies finished state" do
      game.end!
      expect(game.waiting?).to be false
      expect(game.playing?).to be false
      expect(game.finished?).to be true
    end
  end

  describe "#process_move" do
    let(:move_data) { { type: "place_piece", position: { x: 3, y: 4 } } }

    context "when game is playing" do
      before do
        game.add_player(alice)
        game.add_player(bob)
        game.start!
      end

      it "processes valid moves" do
        move = BoardGameCore::Move.new(player: alice, data: move_data)
        result = game.process_move(move)
        expect(result).to be true
      end

      it "adds move to history" do
        move = BoardGameCore::Move.new(player: alice, data: move_data)
        game.process_move(move)
        expect(game.moves).to include(move)
      end

      it "advances turn after successful move" do
        move = BoardGameCore::Move.new(player: alice, data: move_data)
        game.process_move(move)
        expect(game.current_player).to eq(bob)
      end

      it "rejects invalid moves" do
        move = BoardGameCore::Move.new(player: bob, data: move_data) # Bob's turn is not first
        result = game.process_move(move)
        expect(result).to be false
      end

      it "does not advance turn for invalid moves" do
        move = BoardGameCore::Move.new(player: bob, data: move_data)
        game.process_move(move)
        expect(game.current_player).to eq(alice)
      end
    end

    context "when game is not playing" do
      it "rejects moves" do
        move = BoardGameCore::Move.new(player: alice, data: move_data)
        result = game.process_move(move)
        expect(result).to be false
      end
    end
  end

  describe "#moves" do
    it "returns empty array initially" do
      expect(game.moves).to eq([])
    end

    it "returns all processed moves" do
      game.add_player(alice)
      game.add_player(bob)
      game.start!

      move1 = BoardGameCore::Move.new(player: alice, data: { type: "move1" })
      move2 = BoardGameCore::Move.new(player: bob, data: { type: "move2" })

      game.process_move(move1)
      game.process_move(move2)

      expect(game.moves).to eq([move1, move2])
    end
  end

  describe "#last_move" do
    it "returns nil when no moves" do
      expect(game.last_move).to be_nil
    end

    it "returns the last processed move" do
      game.add_player(alice)
      game.add_player(bob)
      game.start!

      move1 = BoardGameCore::Move.new(player: alice, data: { type: "move1" })
      move2 = BoardGameCore::Move.new(player: bob, data: { type: "move2" })

      game.process_move(move1)
      game.process_move(move2)

      expect(game.last_move).to eq(move2)
    end
  end

  describe "#to_h" do
    it "returns id" do
      expect(game.to_h[:id]).to eq("test_game")
    end

    it "returns state" do
      expect(game.to_h[:state]).to eq(:waiting)
    end

    it "returns players as hashes" do
      game.add_player(alice)
      expect(game.to_h[:players]).to eq([alice.to_h])
    end

    it "returns current_player_index" do
      expect(game.to_h[:current_player_index]).to eq(0)
    end

    it "returns current_player" do
      game.add_player(alice)
      game.add_player(bob)
      game.start!
      expect(game.to_h[:current_player]).to eq(alice.to_h)
    end

    it "returns metadata" do
      metadata = { max_score: 100 }
      game = described_class.new(id: "test_game", metadata: metadata)
      expect(game.to_h[:metadata]).to eq(metadata)
    end

    it "returns moves as hashes" do
      game.add_player(alice)
      game.add_player(bob)
      game.start!

      move = BoardGameCore::Move.new(player: alice, data: { type: "test" })
      game.process_move(move)

      expect(game.to_h[:moves]).to eq([move.to_h])
    end
  end
end
