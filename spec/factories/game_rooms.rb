# frozen_string_literal: true

FactoryBot.define do
  factory :game_room, class: "BoardGameCore::GameRoom" do
    sequence(:name) { |n| "Game Room #{n}" }
    host_player factory: %i[player]
    max_players { 4 }

    initialize_with { new(id: id, name: name, host_player: host_player, max_players: max_players) }

    # Traits for different player counts
    trait :small_room do
      max_players { 2 }
    end

    trait :large_room do
      max_players { 6 }
    end

    trait :huge_room do
      max_players { 8 }
    end

    # Trait for room with game created
    trait :with_game do
      after(:create, &:create_game!)
    end

    # Trait for room with game started
    trait :with_started_game do
      after(:create) do |room|
        # Add host player to game
        room.create_game!
        room.add_player(room.host_player)

        # Add one more player to meet minimum requirements
        additional_player = create(:player)
        room.add_player(additional_player)

        room.start_game!
      end
    end

    # Trait for room that's full
    trait :full do
      after(:create) do |room|
        room.create_game!
        room.add_player(room.host_player)

        # Add players up to max_players
        (room.max_players - 1).times do
          player = create(:player)
          room.add_player(player)
        end
      end
    end

    # Trait for empty room (just the host)
    trait :empty do
      # Default state - no additional players
    end

    # Trait for room with some players
    trait :with_players do
      after(:create) do |room|
        room.create_game!
        room.add_player(room.host_player)

        # Add 2 more players
        2.times do
          player = create(:player, :connected)
          room.add_player(player)
        end
      end
    end

    # Trait for room with specific name
    trait :named_room do
      name { "Epic Battle Arena" }
    end

    # Trait for room with connected players
    trait :with_connected_players do
      after(:create) do |room|
        room.create_game!
        room.host_player.connect!
        room.add_player(room.host_player)

        2.times do
          player = create(:player, :connected)
          room.add_player(player)
        end
      end
    end

    # Trait for room ready to start (has minimum players)
    trait :ready_to_start do
      after(:create) do |room|
        room.create_game!
        room.add_player(room.host_player)

        # Add one more player to meet minimum requirements
        additional_player = create(:player, :connected)
        room.add_player(additional_player)
      end
    end
  end
end
