require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/events/change_object_status_in_batch_request'

class ChangeObjectStatusInBatchTest < SeatsioTestClient
  def test_change_object_status_in_batch
    chart_key1 = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key1
    chart_key2 = create_test_chart
    event2 = @seatsio.events.create chart_key: chart_key2

    res = @seatsio.events.change_object_status_in_batch([{ :event => event1.key, :objects => ['A-1'], :status => 'foo'}, { :event => event2.key, :objects => ['A-2'], :status => 'fa'}])

    assert_equal('foo', res[0].objects['A-1'].status)
    assert_equal('foo', @seatsio.events.retrieve_object_info(key: event1.key, label: 'A-1').status)

    assert_equal('fa', res[1].objects['A-2'].status)
    assert_equal('fa', @seatsio.events.retrieve_object_info(key: event2.key, label: 'A-2').status)
  end

  def test_channel_keys
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.update_channels key: event.key, channels: {
        "channelKey1" => {"name" => "channel 1", "color" => "#FF0000", "index" => 1}
    }
    @seatsio.events.assign_objects_to_channels key: event.key, channelConfig: {
        "channelKey1" => ["A-1"]
    }

    res = @seatsio.events.change_object_status_in_batch([{ :event => event.key, :objects => ['A-1'], :status => 'foo', :channelKeys => ['channelKey1']}])

    assert_equal('foo', res[0].objects['A-1'].status)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.update_channels key: event.key, channels: {
        "channelKey1" => {"name" => "channel 1", "color" => "#FF0000", "index" => 1}
    }
    @seatsio.events.assign_objects_to_channels key: event.key, channelConfig: {
        "channelKey1" => ["A-1"]
    }

    res = @seatsio.events.change_object_status_in_batch([{ :event => event.key, :objects => ['A-1'], :status => 'foo', :ignoreChannels => true}])

    assert_equal('foo', res[0].objects['A-1'].status)
  end
end
