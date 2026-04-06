# BoardGameCore

A Ruby gem that provides backend abstractions for turn-based board games with built-in state management, lobby system, and networking capabilities.

## Features

- **Game Management**: Core game logic with state tracking and turn management
- **Player Management**: Player connections, metadata, and status tracking  
- **Game Rooms**: Lobby system for organizing games and managing players
- **Real-time Communication**: Configurable broadcasting with Redis and ActionCable support
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

### Basic Configuration

```ruby
BoardGameCore.configure do |config|
  config.redis_url = "redis://localhost:6379/0"
  config.channel_prefix = "my_game_app"
end
```

### Broadcasting Adapters

BoardGameCore supports two broadcasting strategies:

#### Redis Adapter (Default)
Perfect for non-Rails applications or when you want direct Redis pub/sub control:

```ruby
BoardGameCore.configure do |config|
  config.broadcaster_adapter = :redis
  config.redis_url = "redis://localhost:6379/0"
  config.channel_prefix = "board_game_core"
end
```

#### ActionCable Adapter  
Ideal for Rails applications using ActionCable WebSockets:

```ruby
BoardGameCore.configure do |config|
  config.broadcaster_adapter = :action_cable
end
```

**Rails Integration Example:**

```ruby
# config/initializers/board_game_core.rb
BoardGameCore.configure do |config|
  config.broadcaster_adapter = :action_cable
  config.channel_prefix = "my_game"
end

# app/channels/game_room_channel.rb
class GameRoomChannel < ApplicationCable::Channel
  def subscribed
    # ActionCable automatically receives BoardGameCore broadcasts
    stream_from "game_room_#{params[:room_id]}"
  end
end
```

### Timezone Considerations

BoardGameCore uses `Time.now` for all timestamps to ensure compatibility with both Rails and non-Rails environments. 

**For Rails applications:** If you need timezone-aware timestamps for user display, consider formatting them in your views or controllers using your Rails app's configured timezone:

```ruby
# In your Rails controller/view
game_room.created_at.in_time_zone(current_user.time_zone)
```

The gem's timestamps are primarily used for event ordering and debugging rather than direct user display.

## Basic Usage

### Creating Players

```ruby
player1 = BoardGameCore::Player.new(id: "player_1", name: "Alice")
player2 = BoardGameCore::Player.new(id: "player_2", name: "Bob")

player1.connect!
player2.connect!
```

### Setting up a Game Room

Before `create_game!`, guests join the lobby with `add_player` (they appear in `room.players`). The **host** is not in that list but is merged in when the game is created (if they are `connect!`ed). Only **connected** players are copied into the new `Game`; anyone else can still be added with `add_player` while the game is waiting.

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

# End game with winner and result
game.end!(winner: player1, result: :win)
puts game.winner.name # => "Alice"
puts game.result # => :win
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

#### With Redis Adapter

```ruby
# Subscribe to room events
BoardGameCore::Broadcaster.subscribe_to_room(room.id) do |message|
  puts "Event: #{message[:event]}"
  puts "Data: #{message[:data]}"
end

# Broadcast custom events
BoardGameCore::Broadcaster.broadcast_to_room(room, :custom_event, { data: "value" })
```

#### With ActionCable Adapter

```ruby
# Broadcasting automatically goes to ActionCable channels
BoardGameCore::Broadcaster.broadcast_to_room(room, :move_made, move_data)

# Received in your Rails ActionCable channel as:
# {
#   event: "move_made",
#   data: { ... },
#   timestamp: "2024-01-15T10:30:00-05:00"
# }
```

## Extending Games for Custom Logic

### Using the Post-Move Hook

The `Game` class provides an `after_move_processed` hook that runs **after** the move is recorded in history and **before** the turn advances to the next player. If your hook calls `end!` (for example when someone wins), the turn **does not** advance, so `current_player_index` still refers to the player who just moved. This fits win/draw detection in games like tic-tac-toe.

```ruby
class TicTacToeGame < BoardGameCore::Game
  attr_reader :board, :winner

  def initialize(id:, players: [], metadata: {})
    super
    @board = Array.new(3) { Array.new(3, nil) }
    @winner = nil
  end

  def after_move_processed(move)
    # Update board state based on move
    position = move.data[:position]
    symbol = move.data[:symbol]
    @board[position[:row]][position[:col]] = symbol

    # Check for win condition
    if check_win?(symbol, position)
      end!(winner: move.player, result: :win)
    elsif board_full?
      end!(result: :draw)
    end
  end

  private

  def check_win?(symbol, position)
    # Implement win detection logic
    # Check row, column, and diagonals
  end

  def board_full?
    @board.flatten.none?(&:nil?)
  end
end
```

**Note:** The `result` parameter accepts `:win`, `:draw`, or `:forfeit`. The `winner` and `result` attributes are automatically included in the game's `to_h` serialization. You can access them via `game.winner` and `game.result` after calling `end!`.

### Redis and broadcasting

The default **Redis** broadcaster needs a running Redis server at `config.redis_url` (or `REDIS_URL`) whenever you call methods that publish or subscribe (for example `ChatMessage#send!`, room events, or `Broadcaster.subscribe_to_room`). Core objects like `Game`, `Move`, and `Player` work without Redis; use **ActionCable** in Rails if you prefer WebSockets instead of Redis pub/sub.

### Custom Move Classes

You can also subclass `Move` to add game-specific validation:

```ruby
class TicTacToeMove < BoardGameCore::Move
  def valid?(game)
    return false unless super # Check base validations first

    position = data[:position]
    row = position[:row]
    col = position[:col]

    # Check if position is within bounds
    return false unless row.between?(0, 2) && col.between?(0, 2)

    # Check if position is already taken
    return false unless game.board[row][col].nil?

    true
  end

  def perform_move(game)
    # Additional move logic can be implemented here
    # The base class calls this after validation passes
  end
end
```

## Core Classes

- **`BoardGameCore::Game`**: Manages game state, turns, and players
- **`BoardGameCore::Player`**: Represents individual players with connection status
- **`BoardGameCore::GameRoom`**: Lobby system for organizing games
- **`BoardGameCore::Broadcaster`**: Configurable real-time communication (Redis/ActionCable)
- **`BoardGameCore::ChatMessage`**: In-game chat functionality

## Broadcasting Architecture

The gem uses a flexible adapter pattern for real-time communication:

- **Redis Adapter**: Direct Redis pub/sub for maximum control and non-Rails compatibility
- **ActionCable Adapter**: Seamless Rails integration with WebSocket management
- **Dual Strategy**: You can even run both adapters simultaneously for complex setups

Choose the adapter that best fits your application architecture!

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
