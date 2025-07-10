# frozen_string_literal: true

require_relative "board_game_core/version"
require_relative "board_game_core/game"
require_relative "board_game_core/game_room"
require_relative "board_game_core/player"
require_relative "board_game_core/broadcaster"
require_relative "board_game_core/chat_message"

module BoardGameCore
  class Error < StandardError; end

  # Configuration
  class << self
    attr_accessor :redis_url, :channel_prefix

    def configure
      yield(self)
    end
  end

  # Default configuration
  self.redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
  self.channel_prefix = "board_game_core"
end 