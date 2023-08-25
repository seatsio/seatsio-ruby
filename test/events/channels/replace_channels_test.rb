require 'test_helper'
require 'util'

class ReplaceChannelsTest < SeatsioTestClient

  def test_replace_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    channels = [
      Seatsio::Channel.new("channelKey1", "channel 1", "#FF0000", 1, %w[A-1 A-2]),
      Seatsio::Channel.new("channelKey2", "channel 2", "#0000FF", 2, [])
    ]

    @seatsio.events.channels.replace key: event.key, channels: channels

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(channels, retrieved_event.channels)
  end

end
