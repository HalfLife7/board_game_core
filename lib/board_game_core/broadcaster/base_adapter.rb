# frozen_string_literal: true

module BoardGameCore
  class Broadcaster
    class BaseAdapter
      def broadcast_to_room(room, message)
        raise NotImplementedError, "Subclasses must implement #broadcast_to_room"
      end

      def broadcast_to_player(player, message)
        raise NotImplementedError, "Subclasses must implement #broadcast_to_player"
      end

      def broadcast_to_game(game, message)
        raise NotImplementedError, "Subclasses must implement #broadcast_to_game"
      end

      def subscribe_to_room(room_id, &block)
        raise NotImplementedError, "Subclasses must implement #subscribe_to_room"
      end

      def subscribe_to_player(player_id, &block)
        raise NotImplementedError, "Subclasses must implement #subscribe_to_player"
      end

      def subscribe_to_game(game_id, &block)
        raise NotImplementedError, "Subclasses must implement #subscribe_to_game"
      end
    end
  end
end 