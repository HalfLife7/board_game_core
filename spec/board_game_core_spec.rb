RSpec.describe BoardGameCore do
  it "has a version number" do
    expect(BoardGameCore::VERSION).not_to be nil
  end

  it "can be configured" do
    expect(BoardGameCore).to respond_to(:configure)
    expect(BoardGameCore).to respond_to(:redis_url)
    expect(BoardGameCore).to respond_to(:channel_prefix)
  end

  describe ".configure" do
    it "yields self for configuration" do
      expect { |b| BoardGameCore.configure(&b) }.to yield_with_args(BoardGameCore)
    end

    it "allows setting redis_url" do
      original_url = BoardGameCore.redis_url
      
      BoardGameCore.configure do |config|
        config.redis_url = "redis://test:6379"
      end
      
      expect(BoardGameCore.redis_url).to eq("redis://test:6379")
      
      # Reset
      BoardGameCore.redis_url = original_url
    end
  end
end 