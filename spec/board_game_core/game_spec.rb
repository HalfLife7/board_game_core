RSpec.describe BoardGameCore::Game do
  let(:player1) { BoardGameCore::Player.new(id: "p1", name: "Alice") }
  let(:player2) { BoardGameCore::Player.new(id: "p2", name: "Bob") }
  let(:game) { described_class.new(id: "game_1", players: [player1, player2]) }

  describe "#initialize" do
    it "sets initial state to waiting" do
      expect(game.state).to eq(:waiting)
    end

    it "sets current_player_index to 0" do
      expect(game.current_player_index).to eq(0)
    end

    it "accepts players and metadata" do
      expect(game.players).to eq([player1, player2])
      expect(game.metadata).to eq({})
    end
  end

  describe "#start!" do
    context "with enough players" do
      it "changes state to playing" do
        game.start!
        expect(game.state).to eq(:playing)
      end
    end

    context "with insufficient players" do
      let(:single_player_game) { described_class.new(id: "game_2", players: [player1]) }

      it "raises an error" do
        expect { single_player_game.start! }.to raise_error(BoardGameCore::Error, "Not enough players to start game")
      end
    end
  end

  describe "#current_player" do
    context "when waiting" do
      it "returns nil" do
        expect(game.current_player).to be_nil
      end
    end

    context "when playing" do
      before { game.start! }

      it "returns the first player initially" do
        expect(game.current_player).to eq(player1)
      end
    end
  end

  describe "#next_turn!" do
    context "when not playing" do
      it "returns false" do
        expect(game.next_turn!).to be false
      end
    end

    context "when playing" do
      before { game.start! }

      it "advances to next player" do
        expect(game.current_player).to eq(player1)
        game.next_turn!
        expect(game.current_player).to eq(player2)
      end

      it "wraps around to first player" do
        game.next_turn! # Now player2
        game.next_turn! # Back to player1
        expect(game.current_player).to eq(player1)
      end

      it "returns true on success" do
        expect(game.next_turn!).to be true
      end
    end
  end

  describe "#add_player" do
    let(:player3) { BoardGameCore::Player.new(id: "p3", name: "Charlie") }

    context "when waiting" do
      it "adds the player" do
        expect(game.add_player(player3)).to be true
        expect(game.players).to include(player3)
      end

      it "doesn't add duplicate players" do
        game.add_player(player1) # Already exists
        expect(game.players.count(player1)).to eq(1)
      end
    end

    context "when playing" do
      before { game.start! }

      it "returns false" do
        expect(game.add_player(player3)).to be false
      end
    end
  end

  describe "#remove_player" do
    context "when waiting" do
      it "removes the player" do
        expect(game.remove_player(player1)).to be true
        expect(game.players).not_to include(player1)
      end
    end

    context "when playing" do
      before { game.start! }

      it "returns false" do
        expect(game.remove_player(player1)).to be false
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
      game.start!
      expect(game.waiting?).to be false
      expect(game.playing?).to be true
      expect(game.finished?).to be false
    end

    it "correctly identifies finished state" do
      game.start!
      game.end!
      expect(game.waiting?).to be false
      expect(game.playing?).to be false
      expect(game.finished?).to be true
    end
  end

  describe "#to_h" do
    before { game.start! }

    it "returns a complete hash representation" do
      hash = game.to_h
      expect(hash).to include(
        id: "game_1",
        state: :playing,
        current_player_index: 0,
        metadata: {}
      )
      expect(hash[:players]).to be_an(Array)
      expect(hash[:current_player]).to be_a(Hash)
    end
  end
end 