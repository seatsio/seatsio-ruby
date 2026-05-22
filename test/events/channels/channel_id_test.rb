require 'test_helper'

class ChannelIdTest < SeatsioTestClient

  def test_channel_has_id
    event = @seatsio.events.create chart_key: create_test_chart

    @seatsio.events.channels.add event_key: event.key,
                                 channel_key: "channelKey1",
                                 channel_name: 'channel 1',
                                 channel_color: "#FFFF98",
                                 index: 1,
                                 objects: ['A-1']

    retrieved_event = @seatsio.events.retrieve key: event.key
    channel = retrieved_event.channels.first
    assert_not_nil channel.id
  end

  def test_area_partition_label
    event = @seatsio.events.create chart_key: create_test_chart

    @seatsio.events.channels.add event_key: event.key,
                                 channel_key: "channelKey1",
                                 channel_name: 'channel 1',
                                 channel_color: "#FFFF98",
                                 index: 1,
                                 objects: ['A-1']

    retrieved_event = @seatsio.events.retrieve key: event.key
    channel = retrieved_event.channels.first
    assert_equal "myArea###{channel.id}", channel.area_partition_label("myArea")
  end

end

