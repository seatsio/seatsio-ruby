require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChangeObjectStatusTest < SeatsioTestClient
  def test_change_object_status
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key

    res = @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'status_foo')

    assert_equal('status_foo', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-1').status)
    assert_equal('status_foo', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-2').status)
    assert_equal('free', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-3').status)

    assert_equal({
                   'A-1' => {'own' => {'label' => '1', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}},
                   'A-2' => {'own' => {'label' => '2', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}}
                 }, res.labels)
  end

  def test_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token)

    @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'status_foo', hold_token.hold_token)

    status1 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal('status_foo', status1.status)
    assert_nil(status1.hold_token)

    status2 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'
    assert_equal('status_foo', status2.status)
    assert_nil(status2.hold_token)

  end

  def test_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key

    @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'status_foo', nil, 'myOrder')
    assert_equal('myOrder', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-1').order_id)
    assert_equal('myOrder', @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-2').order_id)
  end

  def test_ticket_type
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
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
    event = @seatsio.events.create key: chart_key
    props1 = {:objectId => 'GA1', :quantity => 5}
    props2 = {:objectId => 'GA2', :quantity => 10}

    @seatsio.events.change_object_status(event.key, [props1, props2], 'status_foo')
    assert_equal(5, @seatsio.events.retrieve_object_status(key: event.key, object_key: 'GA1').quantity)
    assert_equal(10, @seatsio.events.retrieve_object_status(key: event.key, object_key: 'GA2').quantity)
  end

  def test_change_object_status_with_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    props1 = {:objectId => 'A-1', :extraData => {'foo': 'bar'}}
    props2 = {:objectId => 'A-2', :extraData => {'foo': 'baz'}}

    @seatsio.events.change_object_status(event.key, [props1, props2], 'status_foo')

    object1_status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    object2_status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'

    assert_equal({'foo' => 'bar'}, object1_status.extra_data)
    assert_equal({'foo' => 'baz'}, object2_status.extra_data)
  end
end
