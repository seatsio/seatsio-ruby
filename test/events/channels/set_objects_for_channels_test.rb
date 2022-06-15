require 'test_helper'
require 'util'

class SetObjectsForChannelsTest < SeatsioTestClient

  def test_set_objects
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: {
        "channelKey1" => {"name" => "channel 1", "color" => "#FF0000", "index" => 1},
        "channelKey2" => {"name" => "channel 2", "color" => "#0000FF", "index" => 2}
    }

    @seatsio.events.channels.set_objects key: event.key, channelConfig: {
        "channelKey1" => ["A-1", "A-2"],
        "channelKey2" => ["A-3"]
    }

    retrieved_event = @seatsio.events.retrieve key: event.key
    expected_channels = [
        Seatsio::Channel.new("channelKey1", "channel 1", "#FF0000", 1, ["A-1", "A-2"]),
        Seatsio::Channel.new("channelKey2", "channel 2", "#0000FF", 2, ["A-3"])
    ]
    assert_equal(expected_channels, retrieved_event.channels)

  end

end
