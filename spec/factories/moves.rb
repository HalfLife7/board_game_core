# frozen_string_literal: true

FactoryBot.define do
  factory :move, class: "BoardGameCore::Move" do
    player
    data { { type: "basic_move", position: { x: 3, y: 4 } } }
    status { :pending }

    initialize_with { new(player: player, data: data, id: id, status: status) }

    # Status traits
    trait :pending do
      status { :pending }
    end

    trait :executed do
      status { :executed }
      after(:build) { |move| move.instance_variable_set(:@executed_at, Time.current) }
    end

    trait :failed do
      status { :failed }
      after(:build) { |move| move.instance_variable_set(:@error_message, "Move validation failed") }
    end

    # Common move types
    trait :place_piece do
      data { { type: "place_piece", position: { x: 3, y: 4 }, piece_id: "knight" } }
    end

    trait :move_piece do
      data { { type: "move_piece", from: { x: 3, y: 4 }, to: { x: 5, y: 6 }, piece_id: "knight" } }
    end

    trait :attack do
      data { { type: "attack", attacker: { x: 3, y: 4 }, target: { x: 5, y: 6 } } }
    end

    trait :pass_turn do
      data { { type: "pass_turn" } }
    end

    trait :surrender do
      data { { type: "surrender" } }
    end

    # Complex move data
    trait :with_metadata do
      data do
        {
          type: "complex_move",
          position: { x: 3, y: 4 },
          metadata: { duration: 5, cost: 10, effect: "heal" }
        }
      end
    end

    # Trait for move with custom ID
    trait :with_custom_id do
      id { "custom_move_id" }
    end
  end
end
