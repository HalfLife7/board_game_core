# frozen_string_literal: true

require "redis"

module BoardGameCore
  class Broadcaster
    class << self
      def broadcast_to_room(room, event, data)
        channel = "#{BoardGameCore.channel_prefix}:room:#{room.id}"
        message = {
          event: event,
          data: data,
          timestamp: Time.current.iso8601
        }
        
        redis.publish(channel, message.to_json)
      end

      def broadcast_to_player(player, event, data)
        channel = "#{BoardGameCore.channel_prefix}:player:#{player.id}"
        message = {
          event: event,
          data: data,
          timestamp: Time.current.iso8601
        }
        
        redis.publish(channel, message.to_json)
      end

      def broadcast_to_game(game, event, data)
        channel = "#{BoardGameCore.channel_prefix}:game:#{game.id}"
        message = {
          event: event,
          data: data,
          timestamp: Time.current.iso8601
        }
        
        redis.publish(channel, message.to_json)
      end

      def subscribe_to_room(room_id, &block)
        channel = "#{BoardGameCore.channel_prefix}:room:#{room_id}"
        subscribe_to_channel(channel, &block)
      end

      def subscribe_to_player(player_id, &block)
        channel = "#{BoardGameCore.channel_prefix}:player:#{player_id}"
        subscribe_to_channel(channel, &block)
      end

      def subscribe_to_game(game_id, &block)
        channel = "#{BoardGameCore.channel_prefix}:game:#{game_id}"
        subscribe_to_channel(channel, &block)
      end

      private

      def redis
        @redis ||= Redis.new(url: BoardGameCore.redis_url)
      end

      def subscribe_to_channel(channel, &block)
        redis.subscribe(channel) do |on|
          on.message do |_, message|
            parsed_message = JSON.parse(message, symbolize_names: true)
            block.call(parsed_message) if block
          end
        end
      end
    end
  end
end 