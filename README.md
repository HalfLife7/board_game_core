# BoardGameCore

A Ruby gem that provides backend abstractions for turn-based board games with built-in state management, lobby system, and networking capabilities.

## Features

- **Game Management**: Core game logic with state tracking and turn management
- **Player Management**: Player connections, metadata, and status tracking  
- **Game Rooms**: Lobby system for organizing games and managing players
- **Real-time Communication**: Redis-based broadcasting for live updates
- **Chat System**: Built-in chat functionality with system messages
- **Rails Integration**: Designed to work seamlessly with Rails applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'board_game_core'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install board_game_core

## Configuration

```ruby
BoardGameCore.configure do |config|
  config.redis_url = "redis://localhost:6379/0"
  config.channel_prefix = "my_game_app"
end
```

## Basic Usage

### Creating Players

```ruby
player1 = BoardGameCore::Player.new(id: "player_1", name: "Alice")
player2 = BoardGameCore::Player.new(id: "player_2", name: "Bob")

player1.connect!
player2.connect!
```

### Setting up a Game Room

```ruby
room = BoardGameCore::GameRoom.new(
  id: "room_1",
  name: "Epic Battle",
  host_player: player1,
  max_players: 4
)

room.add_player(player2)
```

### Creating and Starting a Game

```ruby
room.create_game!(metadata: { board_size: 8 })
room.start_game!

game = room.game
puts game.current_player.name # => "Alice"

game.next_turn!
puts game.current_player.name # => "Bob"
```

### Chat Messages

```ruby
message = BoardGameCore::ChatMessage.chat(
  id: "msg_1",
  player: player1,
  content: "Good luck!",
  room_id: room.id
)

message.send! # Broadcasts to all players in the room
```

### Real-time Broadcasting

```ruby
# Subscribe to room events
BoardGameCore::Broadcaster.subscribe_to_room(room.id) do |message|
  puts "Event: #{message[:event]}"
  puts "Data: #{message[:data]}"
end

# Broadcast custom events
BoardGameCore::Broadcaster.broadcast_to_room(room, :custom_event, { data: "value" })
```

## Core Classes

- **`BoardGameCore::Game`**: Manages game state, turns, and players
- **`BoardGameCore::Player`**: Represents individual players with connection status
- **`BoardGameCore::GameRoom`**: Lobby system for organizing games
- **`BoardGameCore::Broadcaster`**: Redis-based real-time communication
- **`BoardGameCore::ChatMessage`**: In-game chat functionality

## Development

After checking out the repo, run:

```bash
bundle install
```

To run tests:

```bash
bundle exec rspec
```

To run style checks:

```bash
bundle exec rubocop
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/board_game_core.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
