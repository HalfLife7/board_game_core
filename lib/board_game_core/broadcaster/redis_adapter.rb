# frozen_string_literal: true

require "redis"
require "json"

module BoardGameCore
  class Broadcaster
    # RedisAdapter implements broadcasting functionality using Redis pub/sub.
    # It provides real-time messaging capabilities by publishing messages to
    # Redis channels and supporting subscription to room-specific channels.
    class RedisAdapter < BaseAdapter
      def initialize
        super
        @redis = Redis.new(url: BoardGameCore.redis_url)
      end

      def broadcast_to_room(room, message)
        channel = "#{BoardGameCore.channel_prefix}:room:#{room.id}"
        @redis.publish(channel, JSON.generate(message))
      end

      def broadcast_to_player(player, message)
        channel = "#{BoardGameCore.channel_prefix}:player:#{player.id}"
        @redis.publish(channel, JSON.generate(message))
      end

      def broadcast_to_game(game, message)
        channel = "#{BoardGameCore.channel_prefix}:game:#{game.id}"
        @redis.publish(channel, JSON.generate(message))
      end

      def subscribe_to_room(room_id, &block)
        channel = "#{BoardGameCore.channel_prefix}:room:#{room_id}"
        @redis.subscribe(channel) do |on|
          on.message do |_channel, message|
            parsed_message = JSON.parse(message)
            block.call(parsed_message)
          end
        end
      end
    end
  end
end
