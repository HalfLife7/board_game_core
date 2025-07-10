# frozen_string_literal: true

module BoardGameCore
  # ChatMessage represents a message in a game room's chat system.
  # It supports both player chat messages and system messages (like notifications).
  # Messages are automatically timestamped and can be broadcast to rooms.
  class ChatMessage
    attr_reader :id, :player, :content, :room_id, :timestamp, :message_type

    # Simple struct to represent a room with an ID for broadcasting
    Room = Struct.new(:id)

    def initialize(id:, player:, content:, room_id:, message_type: :chat)
      @id = id
      @player = player
      @content = content
      @room_id = room_id
      @message_type = message_type
      @timestamp = Time.now
    end

    def send!
      Broadcaster.broadcast_to_room(
        Room.new(room_id),
        :chat_message,
        to_h
      )
    end

    def system_message?
      message_type == :system
    end

    def chat_message?
      message_type == :chat
    end

    def to_h
      {
        id: id,
        player: player&.to_h,
        content: content,
        room_id: room_id,
        message_type: message_type,
        timestamp: timestamp.strftime("%Y-%m-%dT%H:%M:%S%z")
      }
    end

    # Factory methods for common message types
    class << self
      def chat(id:, player:, content:, room_id:)
        new(id: id, player: player, content: content, room_id: room_id, message_type: :chat)
      end

      def system(id:, content:, room_id:)
        new(id: id, player: nil, content: content, room_id: room_id, message_type: :system)
      end

      def player_joined(id:, player:, room_id:)
        system(
          id: id,
          content: "#{player.name} joined the room",
          room_id: room_id
        )
      end

      def player_left(id:, player:, room_id:)
        system(
          id: id,
          content: "#{player.name} left the room",
          room_id: room_id
        )
      end

      def game_started(id:, room_id:)
        system(
          id: id,
          content: "Game has started!",
          room_id: room_id
        )
      end
    end
  end
end
