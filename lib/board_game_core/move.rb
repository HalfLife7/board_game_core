# frozen_string_literal: true

require "securerandom"

module BoardGameCore
  # Move represents a game action performed by a player.
  # It encapsulates the move data, validation, execution, and state tracking.
  # Moves can be in pending, executed, or failed states and maintain timestamps.
  class Move
    attr_reader :id, :player, :data, :timestamp, :status, :executed_at, :error_message

    def initialize(player:, data:, id: nil, status: :pending)
      @id = id || generate_id
      @player = player
      @data = data
      @timestamp = Time.now
      @status = status
      @executed_at = nil
      @error_message = nil
    end

    def valid?(game)
      return false unless game.playing?
      return false unless game.current_player == player

      # Additional validation can be added here or overridden in subclasses
      true
    end

    def execute!(game)
      if valid?(game)
        @status = :executed
        @executed_at = Time.now
        # Perform the actual move logic here (can be overridden in subclasses)
        perform_move(game)
        true
      else
        @status = :failed
        @error_message = build_error_message(game)
        false
      end
    end

    def pending?
      status == :pending
    end

    def executed?
      status == :executed
    end

    def failed?
      status == :failed
    end

    def to_h
      hash = {
        id: id,
        player: player.to_h,
        data: data,
        status: status,
        timestamp: timestamp
      }

      hash[:executed_at] = executed_at if executed_at
      hash[:error_message] = error_message if error_message

      hash
    end

    private

    def generate_id
      SecureRandom.hex(8)
    end

    def perform_move(game)
      # Base implementation does nothing
      # Subclasses should override this method to implement specific move logic
    end

    def build_error_message(game)
      return "Game is not currently playing" unless game.playing?
      return "It is not #{player.name}'s turn" unless game.current_player == player

      "Invalid move"
    end
  end
end
