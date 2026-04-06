# frozen_string_literal: true

module BoardGameCore
  # GameRoom represents a lobby where players can join before starting a game.
  # Guests are stored in a lobby list until {#create_game!}, which copies the
  # host plus lobby members who are {#connected?} into a new {Game}. Rooms can
  # contain a game instance once created.
  class GameRoom
    attr_reader :id, :name, :game, :host_player, :max_players, :created_at

    def initialize(id:, name:, host_player:, max_players: 4)
      @id = id
      @name = name
      @host_player = host_player
      @max_players = max_players
      @game = nil
      @lobby_players = []
      @created_at = Time.current
    end

    def create_game!(game_class: Game, metadata: {})
      raise Error, "Game already exists" if game

      participants = lobby_participants
      initial_players = participants.select(&:connected?)
      @game = game_class.new(id: "#{id}_game", players: initial_players, metadata: metadata)
      @lobby_players.clear
      @game
    end

    def start_game!
      raise Error, "No game created" unless game

      game.start!
      notify_players(:game_started, game.to_h)
    end

    def add_player(player)
      return false if full?
      return false if game&.playing?

      if game
        success = game.add_player(player)
      else
        return true if @lobby_players.include?(player)

        @lobby_players << player
        success = true
      end
      notify_players(:player_joined, player.to_h) if success
      success
    end

    def remove_player(player)
      success =
        if game
          game.remove_player(player)
        else
          @lobby_players.delete(player)
          true
        end
      notify_players(:player_left, player.to_h) if success
      success
    end

    def players
      game&.players || @lobby_players
    end

    def connected_players
      if game
        players.select(&:connected?)
      else
        lobby_participants.select(&:connected?)
      end
    end

    def full?
      if game
        game.players.length >= max_players
      else
        lobby_participants.length >= max_players
      end
    end

    delegate :empty?, to: :players

    def host?(player)
      host_player == player
    end

    def to_h
      {
        id: id,
        name: name,
        host_player: host_player.to_h,
        max_players: max_players,
        current_players: (game ? players : lobby_participants).length,
        players: players.map(&:to_h),
        game: game&.to_h,
        created_at: created_at
      }
    end

    private

    def lobby_participants
      ([host_player] + @lobby_players).uniq
    end

    def notify_players(event, data)
      Broadcaster.broadcast_to_room(self, event, data)
    end
  end
end
