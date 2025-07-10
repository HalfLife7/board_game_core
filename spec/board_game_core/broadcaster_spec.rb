# frozen_string_literal: true

# Only require ActionCable if we're testing ActionCable functionality
begin
  require "action_cable"
rescue LoadError
  # ActionCable not available - tests will handle this gracefully
end

RSpec.describe BoardGameCore::Broadcaster do
  let(:room) { instance_double(BoardGameCore::GameRoom, id: "room_1") }
  let(:player) { instance_double(BoardGameCore::Player, id: "player_1") }
  let(:game) { instance_double(BoardGameCore::Game, id: "game_1") }
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
      expect do
        described_class.adapter
      end.to raise_error(BoardGameCore::Error, "Unknown broadcaster adapter: unknown")
    end
  end

  describe ".broadcast_to_room" do
    let(:adapter) { instance_double(BoardGameCore::Broadcaster::RedisAdapter) }

    before do
      allow(described_class).to receive(:adapter).and_return(adapter)
      allow(adapter).to receive(:broadcast_to_room)
    end

    it "delegates to the configured adapter" do
      described_class.broadcast_to_room(room, event, data)

      expect(adapter).to have_received(:broadcast_to_room).with(room, hash_including(
                                                                        event: event,
                                                                        data: data,
                                                                        timestamp: kind_of(String)
                                                                      ))
    end
  end

  describe ".broadcast_to_player" do
    let(:adapter) { instance_double(BoardGameCore::Broadcaster::RedisAdapter) }

    before do
      allow(described_class).to receive(:adapter).and_return(adapter)
      allow(adapter).to receive(:broadcast_to_player)
    end

    it "delegates to the configured adapter" do
      described_class.broadcast_to_player(player, event, data)

      expect(adapter).to have_received(:broadcast_to_player).with(
        player,
        hash_including(
          event: event,
          data: data,
          timestamp: kind_of(String)
        )
      )
    end
  end

  describe ".broadcast_to_game" do
    let(:adapter) { instance_double(BoardGameCore::Broadcaster::RedisAdapter) }

    before do
      allow(described_class).to receive(:adapter).and_return(adapter)
      allow(adapter).to receive(:broadcast_to_game)
    end

    it "delegates to the configured adapter" do
      described_class.broadcast_to_game(game, event, data)

      expect(adapter).to have_received(:broadcast_to_game).with(game, hash_including(
                                                                        event: event,
                                                                        data: data,
                                                                        timestamp: kind_of(String)
                                                                      ))
    end
  end

  describe ".subscribe_to_room" do
    let(:adapter) { instance_double(BoardGameCore::Broadcaster::RedisAdapter) }
    let(:block) { proc { |msg| puts msg } }

    before do
      allow(described_class).to receive(:adapter).and_return(adapter)
      allow(adapter).to receive(:subscribe_to_room)
    end

    it "delegates to the configured adapter" do
      described_class.subscribe_to_room("room_1", &block)

      expect(adapter).to have_received(:subscribe_to_room).with("room_1")
    end
  end

  describe "RedisAdapter" do
    let(:redis_adapter) { BoardGameCore::Broadcaster::RedisAdapter.new }
    let(:redis_client) { instance_double(Redis) }

    before do
      allow(Redis).to receive(:new).and_return(redis_client)
      allow(redis_client).to receive(:publish)
    end

    describe "#broadcast_to_room" do
      it "publishes to the correct Redis channel" do
        message = { event: event, data: data, timestamp: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z") }
        expected_channel = "#{BoardGameCore.channel_prefix}:room:#{room.id}"

        redis_adapter.broadcast_to_room(room, message)

        expect(redis_client).to have_received(:publish).with(expected_channel,
                                                             JSON.generate(message))
      end
    end

    describe "#subscribe_to_room" do
      before do
        allow(redis_client).to receive(:subscribe)
      end

      it "subscribes to the correct Redis channel" do
        expected_channel = "#{BoardGameCore.channel_prefix}:room:room_1"

        redis_adapter.subscribe_to_room("room_1") { |msg| puts msg }

        expect(redis_client).to have_received(:subscribe).with(expected_channel)
      end
    end
  end

  describe "ActionCableAdapter" do
    let(:action_cable_adapter) { BoardGameCore::Broadcaster::ActionCableAdapter.new }
    let(:action_cable_server) { instance_double(ActionCable::Server) }

    before do
      action_cable_class = class_double(ActionCable)
      allow(action_cable_class).to receive(:server).and_return(action_cable_server)
      stub_const("ActionCable", action_cable_class)
      allow(action_cable_server).to receive(:broadcast)
    end

    describe "#broadcast_to_room" do
      it "broadcasts to ActionCable channel" do
        message = { event: event, data: data, timestamp: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z") }
        expected_channel = "game_room_#{room.id}"

        action_cable_adapter.broadcast_to_room(room, message)

        expect(action_cable_server).to have_received(:broadcast).with(expected_channel, message)
      end
    end

    describe "#broadcast_to_player" do
      it "broadcasts to player-specific ActionCable channel" do
        message = { event: event, data: data, timestamp: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z") }
        expected_channel = "player_#{player.id}"

        action_cable_adapter.broadcast_to_player(player, message)

        expect(action_cable_server).to have_received(:broadcast).with(expected_channel, message)
      end
    end

    describe "#subscribe_to_room" do
      it "raises NotImplementedError for ActionCable" do
        expect do
          action_cable_adapter.subscribe_to_room("room_1") { |msg| puts msg }
        end.to raise_error(NotImplementedError,
                           "ActionCable subscriptions are handled by Rails channels")
      end
    end
  end
end
