# frozen_string_literal: true

RSpec.describe BoardGameCore::Move do
  let(:alice) { BoardGameCore::Player.new(id: "p1", name: "Alice") }
  let(:bob) { BoardGameCore::Player.new(id: "p2", name: "Bob") }
  let(:game) { BoardGameCore::Game.new(id: "test_game", players: [alice, bob]) }
  let(:move_data) { { type: "place_piece", position: { x: 3, y: 4 }, piece_id: "knight" } }

  describe "#initialize" do
    it "sets the player" do
      move = described_class.new(player: alice, data: move_data)
      expect(move.player).to eq(alice)
    end

    it "sets the move data" do
      move = described_class.new(player: alice, data: move_data)
      expect(move.data).to eq(move_data)
    end

    it "sets the timestamp" do
      move = described_class.new(player: alice, data: move_data)
      expect(move.timestamp).to be_a(Time)
      expect(move.timestamp).to be_within(1).of(Time.now)
    end

    it "generates a unique ID" do
      move1 = described_class.new(player: alice, data: move_data)
      move2 = described_class.new(player: alice, data: move_data)
      expect(move1.id).not_to eq(move2.id)
    end

    it "accepts custom ID" do
      move = described_class.new(player: alice, data: move_data, id: "custom_id")
      expect(move.id).to eq("custom_id")
    end

    it "defaults to pending status" do
      move = described_class.new(player: alice, data: move_data)
      expect(move.status).to eq(:pending)
    end

    it "accepts custom status" do
      move = described_class.new(player: alice, data: move_data, status: :executed)
      expect(move.status).to eq(:executed)
    end
  end

  describe "#valid?" do
    let(:move) { described_class.new(player: alice, data: move_data) }

    it "returns true for valid moves by default" do
      game.add_player(alice)
      game.add_player(bob)
      game.start!
      expect(move.valid?(game)).to be true
    end

    it "returns false if player is not the current player" do
      game.add_player(alice)
      game.add_player(bob)
      game.start!
      game.next_turn! # Now it's Bob's turn

      move = described_class.new(player: alice, data: move_data)
      expect(move.valid?(game)).to be false
    end

    it "returns false if game is not playing" do
      move = described_class.new(player: alice, data: move_data)
      expect(move.valid?(game)).to be false
    end
  end

  describe "#execute!" do
    let(:move) { described_class.new(player: alice, data: move_data) }

    context "when move is valid" do
      before do
        game.add_player(alice)
        game.add_player(bob)
        game.start!
      end

      it "changes status to executed" do
        move.execute!(game)
        expect(move.status).to eq(:executed)
      end

      it "sets execution timestamp" do
        move.execute!(game)
        expect(move.executed_at).to be_a(Time)
        expect(move.executed_at).to be_within(1).of(Time.now)
      end

      it "returns true" do
        expect(move.execute!(game)).to be true
      end
    end

    context "when move is invalid" do
      it "changes status to failed" do
        move.execute!(game)
        expect(move.status).to eq(:failed)
      end

      it "sets error message" do
        move.execute!(game)
        expect(move.error_message).to be_a(String)
      end

      it "returns false" do
        expect(move.execute!(game)).to be false
      end
    end
  end

  describe "#pending?" do
    it "returns true when status is pending" do
      move = described_class.new(player: alice, data: move_data)
      expect(move.pending?).to be true
    end

    it "returns false when status is not pending" do
      move = described_class.new(player: alice, data: move_data, status: :executed)
      expect(move.pending?).to be false
    end
  end

  describe "#executed?" do
    it "returns true when status is executed" do
      move = described_class.new(player: alice, data: move_data, status: :executed)
      expect(move.executed?).to be true
    end

    it "returns false when status is not executed" do
      move = described_class.new(player: alice, data: move_data)
      expect(move.executed?).to be false
    end
  end

  describe "#failed?" do
    it "returns true when status is failed" do
      move = described_class.new(player: alice, data: move_data, status: :failed)
      expect(move.failed?).to be true
    end

    it "returns false when status is not failed" do
      move = described_class.new(player: alice, data: move_data)
      expect(move.failed?).to be false
    end
  end

  describe "#to_h" do
    let(:move) { described_class.new(player: alice, data: move_data) }

    it "returns a hash representation" do
      hash = move.to_h
      expect(hash).to include(
        id: move.id,
        player: alice.to_h,
        data: move_data,
        status: :pending,
        timestamp: move.timestamp
      )
    end

    it "includes executed_at when move is executed" do
      game.add_player(alice)
      game.add_player(bob)
      game.start!
      move.execute!(game)

      hash = move.to_h
      expect(hash[:executed_at]).to eq(move.executed_at)
    end

    it "includes error_message when move has failed" do
      move.execute!(game) # This should fail
      hash = move.to_h
      expect(hash[:error_message]).to eq(move.error_message)
    end
  end
end
