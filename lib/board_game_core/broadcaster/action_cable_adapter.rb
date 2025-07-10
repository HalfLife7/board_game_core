# frozen_string_literal: true

module BoardGameCore
  class Broadcaster
    class ActionCableAdapter < BaseAdapter
      def broadcast_to_room(room, message)
        channel = "game_room_#{room.id}"
        action_cable_server.broadcast(channel, message)
      end

      def broadcast_to_player(player, message)
        channel = "player_#{player.id}"
        action_cable_server.broadcast(channel, message)
      end

      def broadcast_to_game(game, message)
        channel = "game_#{game.id}"
        action_cable_server.broadcast(channel, message)
      end

      def subscribe_to_room(room_id, &block)
        raise NotImplementedError, "ActionCable subscriptions are handled by Rails channels"
      end

      def subscribe_to_player(player_id, &block)
        raise NotImplementedError, "ActionCable subscriptions are handled by Rails channels"
      end

      def subscribe_to_game(game_id, &block)
        raise NotImplementedError, "ActionCable subscriptions are handled by Rails channels"
      end

      private

      def action_cable_server
        unless defined?(ActionCable)
          raise BoardGameCore::Error, "ActionCable is not available. Make sure you're using this in a Rails application."
        end
        
        ActionCable.server
      end
    end
  end
end 