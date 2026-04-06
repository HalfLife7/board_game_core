# frozen_string_literal: true

FactoryBot.define do
  factory :chat_message, class: "BoardGameCore::ChatMessage" do
    player
    content { "Hello everyone!" }
    sequence(:room_id) { |n| "room_#{n}" }
    message_type { :chat }

    initialize_with do
      new(id: id, player: player, content: content, room_id: room_id, message_type: message_type)
    end

    # Message type traits
    trait :chat do
      message_type { :chat }
      content { "This is a chat message" }
    end

    trait :system do
      message_type { :system }
      player { nil }
      content { "This is a system message" }
    end

    # Common system messages
    trait :player_joined do
      message_type { :system }
      player { nil }
      content { "Player joined the room" }
    end

    trait :player_left do
      message_type { :system }
      player { nil }
      content { "Player left the room" }
    end

    trait :game_started do
      message_type { :system }
      player { nil }
      content { "Game has started!" }
    end

    trait :game_ended do
      message_type { :system }
      player { nil }
      content { "Game has ended!" }
    end

    # Content variations
    trait :greeting do
      content { "Hello everyone, ready to play?" }
    end

    trait :goodbye do
      content { "Thanks for the game, see you later!" }
    end

    trait :strategy_talk do
      content { "I think we should focus on the center of the board" }
    end

    trait :celebration do
      content { "Great move! Well played!" }
    end

    trait :long_message do
      content do
        "This is a very long message that contains a lot of text to test \
how the system handles longer chat messages with multiple sentences and detailed explanations."
      end
    end

    # Trait for message with specific room
    trait :in_room do
      transient do
        room_name { "test_room" }
      end

      room_id { room_name }
    end

    # Trait for message with custom ID
    trait :with_custom_id do
      id { "custom_message_id" }
    end

    # Factory methods for common patterns
    factory :player_joined_message, traits: [:player_joined] do
      transient do
        joining_player { nil }
      end

      content { "#{joining_player&.name || 'Player'} joined the room" }
    end

    factory :player_left_message, traits: [:player_left] do
      transient do
        leaving_player { nil }
      end

      content { "#{leaving_player&.name || 'Player'} left the room" }
    end

    factory :game_started_message, traits: [:game_started]
    factory :game_ended_message, traits: [:game_ended]
  end
end
