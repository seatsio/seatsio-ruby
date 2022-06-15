require 'test_helper'
require 'util'

class ReplaceChannelsTest < SeatsioTestClient

  def test_replace_channels
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.channels.replace key: event.key, channels: {
        "channelKey1" => {"name" => "channel 1", "color" => "#FF0000", "index" => 1},
        "channelKey2" => {"name" => "channel 2", "color" => "#0000FF", "index" => 2}
    }

    retrieved_event = @seatsio.events.retrieve key: event.key
    expected_channels = [
        Seatsio::Channel.new("channelKey1", "channel 1", "#FF0000", 1, []),
        Seatsio::Channel.new("channelKey2", "channel 2", "#0000FF", 2, [])
    ]
    assert_equal(expected_channels, retrieved_event.channels)
  end

end
