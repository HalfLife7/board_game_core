RSpec.describe BoardGameCore::Broadcaster do
  let(:room) { double("room", id: "room_1") }
  let(:player) { double("player", id: "player_1") }
  let(:game) { double("game", id: "game_1") }
  let(:event) { :test_event }
  let(:data) { { message: "test" } }

  describe "adapter configuration" do
    after do
      # Reset to default adapter after each test
      BoardGameCore.configure { |config| config.broadcaster_adapter = :redis }
    end

    it "defaults to redis adapter" do
      expect(described_class.adapter).to be_a(BoardGameCore::Broadcaster::RedisAdapter)
    end

    it "can be configured to use action_cable adapter" do
      BoardGameCore.configure { |config| config.broadcaster_adapter = :action_cable }
      expect(described_class.adapter).to be_a(BoardGameCore::Broadcaster::ActionCableAdapter)
    end

    it "raises error for unknown adapter" do
      BoardGameCore.configure { |config| config.broadcaster_adapter = :unknown }
      expect {
        described_class.adapter
      }.to raise_error(BoardGameCore::Error, "Unknown broadcaster adapter: unknown")
    end
  end

  describe ".broadcast_to_room" do
    let(:adapter) { instance_double(BoardGameCore::Broadcaster::RedisAdapter) }

    before do
      allow(described_class).to receive(:adapter).and_return(adapter)
    end

    it "delegates to the configured adapter" do
      expected_message = {
        event: event,
        data: data,
        timestamp: kind_of(String)
      }

      expect(adapter).to receive(:broadcast_to_room).with(room, expected_message)

      described_class.broadcast_to_room(room, event, data)
    end
  end

  describe ".broadcast_to_player" do
    let(:adapter) { instance_double(BoardGameCore::Broadcaster::RedisAdapter) }

    before do
      allow(described_class).to receive(:adapter).and_return(adapter)
    end

    it "delegates to the configured adapter" do
      expected_message = {
        event: event,
        data: data,
        timestamp: kind_of(String)
      }

      expect(adapter).to receive(:broadcast_to_player).with(player, expected_message)

      described_class.broadcast_to_player(player, event, data)
    end
  end

  describe ".broadcast_to_game" do
    let(:adapter) { instance_double(BoardGameCore::Broadcaster::RedisAdapter) }

    before do
      allow(described_class).to receive(:adapter).and_return(adapter)
    end

    it "delegates to the configured adapter" do
      expected_message = {
        event: event,
        data: data,
        timestamp: kind_of(String)
      }

      expect(adapter).to receive(:broadcast_to_game).with(game, expected_message)

      described_class.broadcast_to_game(game, event, data)
    end
  end

  describe ".subscribe_to_room" do
    let(:adapter) { instance_double(BoardGameCore::Broadcaster::RedisAdapter) }
    let(:block) { proc { |msg| puts msg } }

    before do
      allow(described_class).to receive(:adapter).and_return(adapter)
    end

    it "delegates to the configured adapter" do
      expect(adapter).to receive(:subscribe_to_room).with("room_1", &block)

      described_class.subscribe_to_room("room_1", &block)
    end
  end

  describe "RedisAdapter" do
    let(:redis_adapter) { BoardGameCore::Broadcaster::RedisAdapter.new }
    let(:redis_client) { instance_double(Redis) }

    before do
      allow(Redis).to receive(:new).and_return(redis_client)
    end

    describe "#broadcast_to_room" do
      it "publishes to the correct Redis channel" do
        message = { event: event, data: data, timestamp: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z") }
        expected_channel = "#{BoardGameCore.channel_prefix}:room:#{room.id}"

        expect(redis_client).to receive(:publish).with(expected_channel, JSON.generate(message))

        redis_adapter.broadcast_to_room(room, message)
      end
    end

    describe "#subscribe_to_room" do
      it "subscribes to the correct Redis channel" do
        expected_channel = "#{BoardGameCore.channel_prefix}:room:room_1"
        
        expect(redis_client).to receive(:subscribe).with(expected_channel)

        redis_adapter.subscribe_to_room("room_1") { |msg| puts msg }
      end
    end
  end

  describe "ActionCableAdapter" do
    let(:action_cable_adapter) { BoardGameCore::Broadcaster::ActionCableAdapter.new }
    let(:action_cable_server) { double("ActionCable.server") }

    before do
      stub_const("ActionCable", double("ActionCable", server: action_cable_server))
    end

    describe "#broadcast_to_room" do
      it "broadcasts to ActionCable channel" do
        message = { event: event, data: data, timestamp: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z") }
        expected_channel = "game_room_#{room.id}"

        expect(action_cable_server).to receive(:broadcast).with(expected_channel, message)

        action_cable_adapter.broadcast_to_room(room, message)
      end
    end

    describe "#broadcast_to_player" do
      it "broadcasts to player-specific ActionCable channel" do
        message = { event: event, data: data, timestamp: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z") }
        expected_channel = "player_#{player.id}"

        expect(action_cable_server).to receive(:broadcast).with(expected_channel, message)

        action_cable_adapter.broadcast_to_player(player, message)
      end
    end

    describe "#subscribe_to_room" do
      it "raises NotImplementedError for ActionCable" do
        expect {
          action_cable_adapter.subscribe_to_room("room_1") { |msg| puts msg }
        }.to raise_error(NotImplementedError, "ActionCable subscriptions are handled by Rails channels")
      end
    end
  end
end 