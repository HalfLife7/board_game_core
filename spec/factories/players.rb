# frozen_string_literal: true

FactoryBot.define do
  factory :player, class: "BoardGameCore::Player" do
    sequence(:id) { |n| "player_#{n}" }
    sequence(:name) { |n| "Player #{n}" }
    metadata { {} }

    initialize_with { new(id: id, name: name, metadata: metadata) }

    # Traits for connection states
    trait :connected do
      after(:build, &:connect!)
    end

    trait :disconnected do
      after(:build, &:disconnect!)
    end

    # Trait for playrer with metadata
    trait :with_metadata do
      metadata { { level: 1, score: 100, avatar: "knight" } }
    end

    # Trait for host player
    trait :host do
      metadata { { role: "host" } }
    end
  end
end
