require 'test_helper'
require 'util'

class RemoveObjectsFromChannelTest < SeatsioTestClient

  def test_remove_objects_from_channel
    event = @seatsio.events.create chart_key: create_test_chart
    @seatsio.events.channels.add event_key: event.key,
                                 channel_key: "channelKey1",
                                 channel_name: 'channel 1',
                                 channel_color: "#FFFF98",
                                 index: 1,
                                 objects: ['A-1', 'A-2', 'A-3', 'A-4']

    @seatsio.events.channels.remove_objects event_key: event.key,
                                         channel_key: "channelKey1",
                                         objects: ['A-3', 'A-4']

    retrieved_event = @seatsio.events.retrieve key: event.key
    expected_channels = [
      Seatsio::Channel.new("channelKey1", "channel 1", "#FFFF98", 1, ['A-1', 'A-2'])
    ]
    assert_equal(expected_channels, retrieved_event.channels)
  end

end
