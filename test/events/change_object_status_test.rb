require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChangeObjectStatusTest < SeatsioTestClient
  def test_change_object_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    res = @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'status_foo')

    assert_equal('status_foo', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-1').status)
    assert_equal('status_foo', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-2').status)
    assert_equal('free', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-3').status)

    a1 = res.objects['A-1']
    assert_equal('status_foo', a1.status)
    assert_equal('A-1', a1.label)
    assert_equal({'own' => {'label' => '1', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}}, a1.labels)
    assert_equal('Cat1', a1.category_label)
    assert_equal('9', a1.category_key)
    assert_nil(a1.ticket_type)
    assert_nil(a1.order_id)
    assert_equal('seat', a1.object_type)
    assert_equal(true, a1.for_sale)
    assert_nil(a1.section)
    assert_nil(a1.entrance)
    assert_nil(a1.num_booked)
    assert_nil(a1.capacity)
    assert_nil(a1.left_neighbour)
    assert_equal('A-2', a1.right_neighbour)
  end

  def test_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token)

    @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'status_foo', hold_token: hold_token.hold_token)

    status1 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal('status_foo', status1.status)
    assert_nil(status1.hold_token)

    status2 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'
    assert_equal('status_foo', status2.status)
    assert_nil(status2.hold_token)

  end

  def test_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'status_foo', order_id: 'myOrder')
    assert_equal('myOrder', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-1').order_id)
    assert_equal('myOrder', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-2').order_id)
  end

  def test_ticket_type
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    props1 = {:objectId => 'A-1', :ticketType => 'Ticket Type 1'}
    props2 = {:objectId => 'A-2', :ticketType => 'Ticket Type 2'}

    @seatsio.events.change_object_status(event.key, [props1, props2], 'status_foo')

    status1 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal('status_foo', status1.status)
    assert_equal('Ticket Type 1', status1.ticket_type)

    status2 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'
    assert_equal('status_foo', status2.status)
    assert_equal('Ticket Type 2', status2.ticket_type)
  end

  def test_quantity
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    props1 = {:objectId => 'GA1', :quantity => 5}
    props2 = {:objectId => 'GA2', :quantity => 10}

    @seatsio.events.change_object_status(event.key, [props1, props2], 'status_foo')
    assert_equal(5, @seatsio.events.retrieve_object_status(key: event.key, object_key: 'GA1').quantity)
    assert_equal(10, @seatsio.events.retrieve_object_status(key: event.key, object_key: 'GA2').quantity)
  end

  def test_change_object_status_with_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    props1 = {:objectId => 'A-1', :extraData => {'foo': 'bar'}}
    props2 = {:objectId => 'A-2', :extraData => {'foo': 'baz'}}

    @seatsio.events.change_object_status(event.key, [props1, props2], 'status_foo')

    object1_status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    object2_status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'

    assert_equal({'foo' => 'bar'}, object1_status.extra_data)
    assert_equal({'foo' => 'baz'}, object2_status.extra_data)
  end

  def test_keep_extra_data_true
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_object_status(event.key, 'A-1', 'someStatus', keep_extra_data: true)

    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(extra_data, status.extra_data)
  end

  def test_keep_extra_data_false
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_object_status(event.key, 'A-1', 'someStatus', keep_extra_data: false)

    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_nil(nil, status.extra_data)
  end

  def test_no_keep_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_object_status(event.key, 'A-1', 'someStatus')

    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_nil(nil, status.extra_data)
  end

  def test_channel_keys
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.update_channels key: event.key, channels: {
        "channelKey1" => {"name" => "channel 1", "color" => "#FF0000", "index" => 1}
    }
    @seatsio.events.assign_objects_to_channels key: event.key, channelConfig: {
        "channelKey1" => ["A-1", "A-2"]
    }

    @seatsio.events.change_object_status(event.key, 'A-1', "someStatus", channel_keys: ["channelKey1"])

    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal("someStatus", status.status)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.update_channels key: event.key, channels: {
        "channelKey1" => {"name" => "channel 1", "color" => "#FF0000", "index" => 1}
    }
    @seatsio.events.assign_objects_to_channels key: event.key, channelConfig: {
        "channelKey1" => ["A-1", "A-2"]
    }

    @seatsio.events.change_object_status(event.key, 'A-1', "someStatus", ignore_channels: true)

    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal("someStatus", status.status)
  end
end
