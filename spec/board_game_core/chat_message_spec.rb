# frozen_string_literal: true

RSpec.describe BoardGameCore::ChatMessage do
  let(:player) { build(:player, id: "p1", name: "Alice") }
  let(:room_id) { "room_1" }
  let(:message) do
    build(:chat_message, id: "msg_1", player: player, content: "Hello!", room_id: room_id)
  end

  describe "#initialize" do
    it "sets the id" do
      expect(message.id).to eq("msg_1")
    end

    it "sets the player" do
      expect(message.player).to eq(player)
    end

    it "sets the content" do
      expect(message.content).to eq("Hello!")
    end

    it "sets the room_id" do
      expect(message.room_id).to eq(room_id)
    end

    it "defaults message_type to :chat" do
      expect(message.message_type).to eq(:chat)
    end

    it "accepts custom message_type" do
      msg = described_class.new(
        id: "msg_2",
        player: nil,
        content: "System message",
        room_id: room_id,
        message_type: :system
      )
      expect(msg.message_type).to eq(:system)
    end

    it "sets timestamp" do
      expect(message.timestamp).to be_a(Time)
      expect(message.timestamp).to be_within(1).of(Time.current)
    end
  end

  describe "#send!" do
    it "broadcasts to room" do
      expect(BoardGameCore::Broadcaster).to receive(:broadcast_to_room).with(
        an_instance_of(BoardGameCore::ChatMessage::Room),
        :chat_message,
        message.to_h
      )
      message.send!
    end

    it "uses room_id for broadcasting" do
      room_struct = nil
      allow(BoardGameCore::Broadcaster).to receive(:broadcast_to_room) do |room, _event, _data|
        room_struct = room
      end
      message.send!
      expect(room_struct.id).to eq(room_id)
    end
  end

  describe "#system_message?" do
    it "returns true for system messages" do
      msg = build(:chat_message, :system, room_id: room_id)
      expect(msg.system_message?).to be true
    end

    it "returns false for chat messages" do
      expect(message.system_message?).to be false
    end
  end

  describe "#chat_message?" do
    it "returns true for chat messages" do
      expect(message.chat_message?).to be true
    end

    it "returns false for system messages" do
      msg = build(:chat_message, :system, room_id: room_id)
      expect(msg.chat_message?).to be false
    end
  end

  describe "#to_h" do
    it "returns id" do
      expect(message.to_h[:id]).to eq("msg_1")
    end

    it "returns player as hash" do
      expect(message.to_h[:player]).to eq(player.to_h)
    end

    it "returns nil for player when system message" do
      msg = build(:chat_message, :system, room_id: room_id)
      expect(msg.to_h[:player]).to be_nil
    end

    it "returns content" do
      expect(message.to_h[:content]).to eq("Hello!")
    end

    it "returns room_id" do
      expect(message.to_h[:room_id]).to eq(room_id)
    end

    it "returns message_type" do
      expect(message.to_h[:message_type]).to eq(:chat)
    end

    it "returns formatted timestamp" do
      timestamp_str = message.to_h[:timestamp]
      expect(timestamp_str).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4}/)
    end
  end

  describe ".chat" do
    it "creates a chat message" do
      msg = described_class.chat(
        id: "msg_2",
        player: player,
        content: "Test",
        room_id: room_id
      )
      expect(msg.message_type).to eq(:chat)
      expect(msg.player).to eq(player)
      expect(msg.content).to eq("Test")
    end
  end

  describe ".system" do
    it "creates a system message" do
      msg = described_class.system(
        id: "msg_3",
        content: "System notification",
        room_id: room_id
      )
      expect(msg.message_type).to eq(:system)
      expect(msg.player).to be_nil
      expect(msg.content).to eq("System notification")
    end
  end

  describe ".player_joined" do
    it "creates a system message for player joined" do
      msg = described_class.player_joined(
        id: "msg_4",
        player: player,
        room_id: room_id
      )
      expect(msg.message_type).to eq(:system)
      expect(msg.player).to be_nil
      expect(msg.content).to eq("Alice joined the room")
    end
  end

  describe ".player_left" do
    it "creates a system message for player left" do
      msg = described_class.player_left(
        id: "msg_5",
        player: player,
        room_id: room_id
      )
      expect(msg.message_type).to eq(:system)
      expect(msg.player).to be_nil
      expect(msg.content).to eq("Alice left the room")
    end
  end

  describe ".game_started" do
    it "creates a system message for game started" do
      msg = described_class.game_started(
        id: "msg_6",
        room_id: room_id
      )
      expect(msg.message_type).to eq(:system)
      expect(msg.player).to be_nil
      expect(msg.content).to eq("Game has started!")
    end
  end

  describe "Room struct" do
    it "is defined" do
      expect(described_class::Room).to be_a(Class)
    end

    it "can be instantiated with id" do
      room = described_class::Room.new("test_room")
      expect(room.id).to eq("test_room")
    end
  end
end




