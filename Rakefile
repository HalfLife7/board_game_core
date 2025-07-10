# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]

desc "Run all tests"
task test: :spec

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -r bundler/setup -r board_game_core"
end
