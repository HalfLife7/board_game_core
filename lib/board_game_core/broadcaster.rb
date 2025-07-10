# frozen_string_literal: true

module BoardGameCore
  class Broadcaster
    class << self
      def broadcast_to_room(room, event, data)
        message = build_message(event, data)
        adapter.broadcast_to_room(room, message)
      end

      def broadcast_to_player(player, event, data)
        message = build_message(event, data)
        adapter.broadcast_to_player(player, message)
      end

      def broadcast_to_game(game, event, data)
        message = build_message(event, data)
        adapter.broadcast_to_game(game, message)
      end

      def subscribe_to_room(room_id, &block)
        adapter.subscribe_to_room(room_id, &block)
      end

      def subscribe_to_player(player_id, &block)
        adapter.subscribe_to_player(player_id, &block)
      end

      def subscribe_to_game(game_id, &block)
        adapter.subscribe_to_game(game_id, &block)
      end

      def adapter
        @adapter ||= create_adapter
      end

      def reset_adapter!
        @adapter = nil
      end

      private

      def build_message(event, data)
        {
          event: event,
          data: data,
          timestamp: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")
        }
      end

      def create_adapter
        case BoardGameCore.broadcaster_adapter
        when :redis
          RedisAdapter.new
        when :action_cable
          ActionCableAdapter.new
        else
          raise Error, "Unknown broadcaster adapter: #{BoardGameCore.broadcaster_adapter}"
        end
      end
    end
  end
end 