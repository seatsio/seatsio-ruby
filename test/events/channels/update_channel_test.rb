require 'test_helper'
require 'util'

class UpdateChannelTest < SeatsioTestClient

  def test_update_name
    event = @seatsio.events.create chart_key: create_test_chart
    @seatsio.events.channels.add event_key: event.key,
                                 channel_key: "channelKey1",
                                 channel_name: 'channel 1',
                                 channel_color: "#FFFF98",
                                 index: 1,
                                 objects: ['A-1', 'A-2']

    @seatsio.events.channels.update event_key: event.key,
                                    channel_key: "channelKey1",
                                    channel_name: 'new channel name'

    retrieved_event = @seatsio.events.retrieve key: event.key
    expected_channels = [
      Seatsio::Channel.new("channelKey1", "new channel name", "#FFFF98", 1, ['A-1', 'A-2']),
    ]
    assert_equal(expected_channels, retrieved_event.channels)
  end

  def test_update_color
    event = @seatsio.events.create chart_key: create_test_chart
    @seatsio.events.channels.add event_key: event.key,
                                 channel_key: "channelKey1",
                                 channel_name: 'channel 1',
                                 channel_color: "#FFFF98",
                                 index: 1,
                                 objects: ['A-1', 'A-2']

    @seatsio.events.channels.update event_key: event.key,
                                    channel_key: "channelKey1",
                                    channel_color: 'red'

    retrieved_event = @seatsio.events.retrieve key: event.key
    expected_channels = [
      Seatsio::Channel.new("channelKey1", "channel 1", "red", 1, ['A-1', 'A-2']),
    ]
    assert_equal(expected_channels, retrieved_event.channels)
  end

  def test_update_objects
    event = @seatsio.events.create chart_key: create_test_chart
    @seatsio.events.channels.add event_key: event.key,
                                 channel_key: "channelKey1",
                                 channel_name: 'channel 1',
                                 channel_color: "#FFFF98",
                                 index: 1,
                                 objects: ['A-1', 'A-2']

    @seatsio.events.channels.update event_key: event.key,
                                    channel_key: "channelKey1",
                                    objects: ['B-1', 'B-2']

    retrieved_event = @seatsio.events.retrieve key: event.key
    expected_channels = [
      Seatsio::Channel.new("channelKey1", "channel 1", "#FFFF98", 1, ['B-1', 'B-2']),
    ]
    assert_equal(expected_channels, retrieved_event.channels)
  end

end
