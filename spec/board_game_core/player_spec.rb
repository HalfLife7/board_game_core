RSpec.describe BoardGameCore::Player do
  let(:player) { described_class.new(id: "player_1", name: "Alice") }

  describe "#initialize" do
    it "sets the id and name" do
      expect(player.id).to eq("player_1")
      expect(player.name).to eq("Alice")
    end

    it "sets connected to false by default" do
      expect(player.connected?).to be false
    end

    it "accepts metadata" do
      player_with_metadata = described_class.new(
        id: "player_2", 
        name: "Bob", 
        metadata: { avatar: "knight" }
      )
      expect(player_with_metadata.metadata).to eq({ avatar: "knight" })
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

  describe "#==" do
    it "returns true for players with same id" do
      other_player = described_class.new(id: "player_1", name: "Different Name")
      expect(player).to eq(other_player)
    end

    it "returns false for players with different id" do
      other_player = described_class.new(id: "player_2", name: "Alice")
      expect(player).not_to eq(other_player)
    end

    it "returns false for non-player objects" do
      expect(player).not_to eq("not a player")
    end
  end

  describe "#to_h" do
    it "returns a hash representation" do
      player.connect!
      player.metadata[:score] = 100

      hash = player.to_h
      expect(hash).to eq({
        id: "player_1",
        name: "Alice",
        connected: true,
        metadata: { score: 100 }
      })
    end
  end
end 