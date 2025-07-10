# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "board_game_core"
  spec.version       = "0.1.0"
  spec.authors       = ["HalfLife7"]
  # spec.email         = ['your.email@example.com']

  spec.summary       = "Turn-based board game framework for Rails applications"
  spec.description   = "A Ruby gem that provides backend abstractions for turn-based board games " \
                       "with built-in state management, lobby system, and networking capabilities"
  spec.homepage      = "https://github.com/HalfLife7/board_game_core"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/HalfLife7/board_game_core"
  spec.metadata["changelog_uri"] = "https://github.com/HalfLife7/board_game_core/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      excluded_patterns = %r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)}
      (f == __FILE__) || f.match(excluded_patterns)
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "redis", ">= 4.0"
end
