# frozen_string_literal: true

RSpec.describe BoardGameCore do
  it "has a version number" do
    expect(BoardGameCore::VERSION).not_to be_nil
  end

  it "has a default redis_url" do
    expect(described_class.redis_url).to eq("redis://localhost:6379/0")
  end

  it "has a default channel_prefix" do
    expect(described_class.channel_prefix).to eq("board_game_core")
  end

  it "has a default broadcaster_adapter" do
    expect(described_class.broadcaster_adapter).to eq(:redis)
  end

  describe ".configure" do
    after do
      # Reset configuration after each test
      described_class.redis_url = "redis://localhost:6379/0"
      described_class.channel_prefix = "board_game_core"
      described_class.broadcaster_adapter = :redis
    end

    it "allows setting redis_url" do
      described_class.configure do |config|
        config.redis_url = "redis://localhost:6379/1"
      end
      expect(described_class.redis_url).to eq("redis://localhost:6379/1")
    end

    it "allows setting channel_prefix" do
      described_class.configure do |config|
        config.channel_prefix = "custom_prefix"
      end
      expect(described_class.channel_prefix).to eq("custom_prefix")
    end

    it "allows setting broadcaster_adapter" do
      described_class.configure do |config|
        config.broadcaster_adapter = :action_cable
      end
      expect(described_class.broadcaster_adapter).to eq(:action_cable)
    end
  end
end
