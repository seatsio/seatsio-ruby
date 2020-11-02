require 'test_helper'
require 'util'

class HoldObjectsTest < SeatsioTestClient
  def test_with_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    res = @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token)

    status1 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(Seatsio::ObjectStatus::HELD, status1.status)
    assert_equal(hold_token.hold_token, status1.hold_token)

    status2 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'
    assert_equal(Seatsio::ObjectStatus::HELD, status2.status)
    assert_equal(hold_token.hold_token, status2.hold_token)

    assert_equal(res.objects.keys, ['A-1', 'A-2'])
  end

  def test_with_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token, order_id: 'order1')

    status1 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal('order1', status1.order_id)

    status2 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'
    assert_equal('order1', status2.order_id)
  end

  def test_keep_extra_data_true
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data
    hold_token = @seatsio.hold_tokens.create

    @seatsio.events.hold(event.key, 'A-1', hold_token.hold_token, keep_extra_data: true)

    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(extra_data, status.extra_data)
  end

  def test_channel_keys
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.update_channels key: event.key, channels: {
        "channelKey1" => {"name" => "channel 1", "color" => "#FF0000", "index" => 1}
    }
    @seatsio.events.assign_objects_to_channels key: event.key, channelConfig: {
        "channelKey1" => ["A-1", "A-2"]
    }

    @seatsio.events.hold(event.key, 'A-1', hold_token.hold_token, channel_keys: ["channelKey1"])

    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(Seatsio::ObjectStatus::HELD, status.status)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.update_channels key: event.key, channels: {
        "channelKey1" => {"name" => "channel 1", "color" => "#FF0000", "index" => 1}
    }
    @seatsio.events.assign_objects_to_channels key: event.key, channelConfig: {
        "channelKey1" => ["A-1", "A-2"]
    }

    @seatsio.events.hold(event.key, 'A-1', hold_token.hold_token, ignore_channels: true)

    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(Seatsio::ObjectStatus::HELD, status.status)
  end
end
