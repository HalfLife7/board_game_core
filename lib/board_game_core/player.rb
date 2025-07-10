# frozen_string_literal: true

module BoardGameCore
  # Player represents a game participant with identity, connection status, and metadata.
  # Players can be connected or disconnected, and support custom metadata for game-specific data.
  # Players are considered equal if they have the same ID, making them suitable for collections.
  class Player
    attr_reader :id, :name, :metadata
    attr_accessor :connected

    def initialize(id:, name:, metadata: {})
      @id = id
      @name = name
      @metadata = metadata
      @connected = false
    end

    def connect!
      @connected = true
    end

    def disconnect!
      @connected = false
    end

    def connected?
      @connected
    end

    def ==(other)
      other.is_a?(Player) && id == other.id
    end

    def eql?(other)
      self == other
    end

    def hash
      id.hash
    end

    def to_h
      {
        id: id,
        name: name,
        connected: connected?,
        metadata: metadata
      }
    end
  end
end
