# frozen_string_literal: true

module BoardGameCore
  # Game represents a board game instance with state management and turn-based gameplay.
  # It manages players, game state (waiting, playing, finished), and turn progression.
  # Games support metadata for game-specific data and provide methods for player management.
  class Game
    attr_reader :id, :state, :players, :current_player_index, :metadata, :moves

    def initialize(id:, players: [], metadata: {})
      @id = id
      @state = :waiting
      @players = players
      @current_player_index = 0
      @metadata = metadata
      @moves = []
    end

    def start!
      raise Error, "Not enough players to start game" if players.length < 2

      @state = :playing
    end

    def end!
      @state = :finished
    end

    def current_player
      return nil unless playing?

      players[current_player_index]
    end

    def next_turn!
      return false unless playing?

      @current_player_index = (current_player_index + 1) % players.length
      true
    end

    def add_player(player)
      return false if playing? || finished?

      @players << player unless players.include?(player)
      true
    end

    def remove_player(player)
      return false if playing?

      @players.delete(player)
      true
    end

    def waiting?
      state == :waiting
    end

    def playing?
      state == :playing
    end

    def finished?
      state == :finished
    end

    def process_move(move)
      return false unless playing?

      success = move.execute!(self)
      if success
        @moves << move
        next_turn!
      end
      success
    end

    def last_move
      moves.last
    end

    def to_h
      {
        id: id,
        state: state,
        players: players.map(&:to_h),
        current_player_index: current_player_index,
        current_player: current_player&.to_h,
        metadata: metadata,
        moves: moves.map(&:to_h)
      }
    end
  end
end
