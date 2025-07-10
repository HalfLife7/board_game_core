# frozen_string_literal: true

require "bundler/setup"
require "board_game_core"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Object`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Use consistent order
  config.order = :random

  # Seed global randomization in this process
  Kernel.srand config.seed

  # Reset configuration after each test
  config.after do
    BoardGameCore.broadcaster_adapter = :redis
    BoardGameCore::Broadcaster.reset_adapter!
  end
end
