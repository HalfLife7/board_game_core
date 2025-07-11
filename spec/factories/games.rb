# frozen_string_literal: true

FactoryBot.define do
  factory :game, class: "BoardGameCore::Game" do
    players { [] }
    metadata { {} }

    initialize_with { new(id: id, players: players, metadata: metadata) }

    # Trait for game with two players
    trait :with_players do
      transient do
        player_count { 2 }
      end

      after(:build) do |game, evaluator|
        build_list(:player, evaluator.player_count).each do |player|
          game.add_player(player)
        end
      end
    end

    # Trait for game with two named players
    trait :with_two_players do
      after(:build) do |game|
        player1 = build(:player, id: "player_1", name: "Alice")
        player2 = build(:player, id: "player_2", name: "Bob")
        game.add_player(player1)
        game.add_player(player2)
      end
    end

    # Trait for game with multiple players
    trait :with_many_players do
      after(:build) do |game|
        4.times do |i|
          player = build(:player, name: "Player #{i + 1}")
          game.add_player(player)
        end
      end
    end

    # State traits
    trait :waiting do
      # Default state, no additional setup needed
    end

    trait :playing do
      with_players
      after(:build, &:start!)
    end

    trait :finished do
      with_players
      after(:build) do |game|
        game.start!
        game.end!
      end
    end

    # Trait for game with metadata
    trait :with_metadata do
      metadata { { max_score: 100, time_limit: 1800, difficulty: "medium" } }
    end

    # Trait for game with moves
    trait :with_moves do
      playing
      after(:build) do |game|
        # Create a few moves
        3.times do |i|
          current_player = game.current_player
          move = build(:move, player: current_player, data: { type: "test_move", step: i + 1 })
          game.process_move(move)
        end
      end
    end

    # Specific game scenarios
    trait :ready_to_start do
      with_players
      # Game has players but hasn't started yet
    end

    trait :mid_game do
      with_moves
      # Game in progress with several moves
    end
  end
end
