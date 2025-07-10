# frozen_string_literal: true

module BoardGameCore
  # GameRoom represents a lobby where players can join before starting a game.
  # It manages room-specific settings like maximum players, hosts game creation,
  # and handles player connections. Rooms can contain a game instance once created.
  class GameRoom
    attr_reader :id, :name, :game, :host_player, :max_players, :created_at

    def initialize(id:, name:, host_player:, max_players: 4)
      @id = id
      @name = name
      @host_player = host_player
      @max_players = max_players
      @game = nil
      @created_at = Time.now
    end

    def create_game!(game_class: Game, metadata: {})
      raise Error, "Game already exists" if game

      @game = game_class.new(id: "#{id}_game", players: connected_players, metadata: metadata)
    end

    def start_game!
      raise Error, "No game created" unless game

      game.start!
      notify_players(:game_started, game.to_h)
    end

    def add_player(player)
      return false if full?
      return false if game&.playing?

      success = game ? game.add_player(player) : true
      notify_players(:player_joined, player.to_h) if success
      success
    end

    def remove_player(player)
      success = game ? game.remove_player(player) : true
      notify_players(:player_left, player.to_h) if success
      success
    end

    def players
      game&.players || []
    end

    def connected_players
      players.select(&:connected?)
    end

    def full?
      players.length >= max_players
    end

    def empty?
      players.empty?
    end

    def host?(player)
      host_player == player
    end

    def to_h
      {
        id: id,
        name: name,
        host_player: host_player.to_h,
        max_players: max_players,
        current_players: players.length,
        players: players.map(&:to_h),
        game: game&.to_h,
        created_at: created_at
      }
    end

    private

    def notify_players(event, data)
      Broadcaster.broadcast_to_room(self, event, data)
    end
  end
end
