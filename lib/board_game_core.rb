# frozen_string_literal: true

require_relative "board_game_core/version"
require_relative "board_game_core/game"
require_relative "board_game_core/game_room"
require_relative "board_game_core/player"
require_relative "board_game_core/move"
require_relative "board_game_core/broadcaster"
require_relative "board_game_core/broadcaster/base_adapter"
require_relative "board_game_core/broadcaster/redis_adapter"
require_relative "board_game_core/broadcaster/action_cable_adapter"
require_relative "board_game_core/chat_message"

# BoardGameCore provides a comprehensive framework for building turn-based board games
# with built-in state management, lobby system, and networking capabilities.
# It supports multiple broadcasting adapters (Redis, ActionCable) and provides
# abstractions for games, players, rooms, and chat functionality.
module BoardGameCore
  class Error < StandardError; end

  # Configuration
  class << self
    attr_accessor :redis_url, :channel_prefix, :broadcaster_adapter

    def configure
      yield(self)
    end
  end

  # Default configuration
  self.redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
  self.channel_prefix = "board_game_core"
  self.broadcaster_adapter = :redis
end
