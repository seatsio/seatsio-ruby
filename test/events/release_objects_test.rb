require 'test_helper'
require 'util'

class ReleaseObjectsTest < SeatsioTestClient
  def test_release_objects
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, %w(A-1 A-2))

    res = @seatsio.events.release(event.key, %w(A-1 A-2))

    a1_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-1').status
    a2_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-2').status
    a3_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-3').status

    assert_equal(Seatsio::EventObjectInfo::FREE, a1_status)
    assert_equal(Seatsio::EventObjectInfo::FREE, a2_status)
    assert_equal(Seatsio::EventObjectInfo::FREE, a3_status)

    assert_equal(res.objects.keys.sort, ['A-1', 'A-2'])
  end

  def test_with_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.hold(event.key, ['A-1'], hold_token.hold_token)

    @seatsio.events.release(event.key, ['A-1'], hold_token: hold_token.hold_token)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::FREE, object_info.status)
    assert_nil(object_info.hold_token)
  end

  def test_with_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, ['A-1'])

    @seatsio.events.release(event.key, ['A-1'], order_id: 'order1')

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal('order1', object_info.order_id)
  end

  def test_keep_extra_data_true
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.book(event.key, [{:objectId => 'A-1', :extraData => extra_data}])

    @seatsio.events.release(event.key, 'A-1', keep_extra_data: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(extra_data, object_info.extra_data)
  end

  def test_channel_keys
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: [
      { "key" => "channelKey1", "name" => "channel 1", "color" => "#FF0000", "index" => 1, "objects" => %w[A-1 A-2] }
    ]
    @seatsio.events.book(event.key, 'A-1', channel_keys: ["channelKey1"])

    @seatsio.events.release(event.key, 'A-1', channel_keys: ["channelKey1"])

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::FREE, object_info.status)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: [
      { "key" => "channelKey1", "name" => "channel 1", "color" => "#FF0000", "index" => 1, "objects" => %w[A-1 A-2] }
    ]
    @seatsio.events.book(event.key, 'A-1', channel_keys: ["channelKey1"])

    @seatsio.events.release(event.key, 'A-1', ignore_channels: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::FREE, object_info.status)
  end
end
