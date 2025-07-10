# frozen_string_literal: true

RSpec.describe BoardGameCore::Player do
  let(:player) { described_class.new(id: "test_id", name: "Test Player") }

  describe "#initialize" do
    it "sets the id" do
      expect(player.id).to eq("test_id")
    end

    it "sets the name" do
      expect(player.name).to eq("Test Player")
    end

    it "defaults to disconnected" do
      expect(player.connected?).to be false
    end

    it "accepts metadata" do
      metadata = { level: 1, score: 100 }
      player = described_class.new(id: "test_id", name: "Test Player", metadata: metadata)
      expect(player.metadata).to eq(metadata)
    end
  end

  describe "#connect!" do
    it "sets connected to true" do
      player.connect!
      expect(player.connected?).to be true
    end
  end

  describe "#disconnect!" do
    it "sets connected to false" do
      player.connect!
      player.disconnect!
      expect(player.connected?).to be false
    end
  end

  describe "#connected?" do
    it "returns connection status" do
      expect(player.connected?).to be false
      player.connect!
      expect(player.connected?).to be true
    end
  end

  describe "#==" do
    it "returns true for players with same ID" do
      other_player = described_class.new(id: "test_id", name: "Different Name")
      expect(player == other_player).to be true
    end

    it "returns false for players with different IDs" do
      other_player = described_class.new(id: "different_id", name: "Test Player")
      expect(player == other_player).to be false
    end

    it "returns false for non-Player objects" do
      expect(player == "not a player").to be false
    end
  end

  describe "#eql?" do
    it "delegates to #==" do
      other_player = described_class.new(id: "test_id", name: "Different Name")
      expect(player.eql?(other_player)).to be true
    end
  end

  describe "#hash" do
    it "returns hash of ID" do
      expect(player.hash).to eq("test_id".hash)
    end
  end

  describe "#to_h" do
    it "returns id" do
      expect(player.to_h[:id]).to eq("test_id")
    end

    it "returns name" do
      expect(player.to_h[:name]).to eq("Test Player")
    end

    it "returns connected status" do
      expect(player.to_h[:connected]).to be false
      player.connect!
      expect(player.to_h[:connected]).to be true
    end

    it "returns metadata" do
      metadata = { level: 1, score: 100 }
      player = described_class.new(id: "test_id", name: "Test Player", metadata: metadata)
      expect(player.to_h[:metadata]).to eq(metadata)
    end
  end
end
