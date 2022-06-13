require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChangeObjectStatusTest < SeatsioTestClient
  def test_change_object_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    res = @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'status_foo')

    assert_equal('status_foo', @seatsio.events.retrieve_object_info(key: event.key, label: 'A-1').status)
    assert_equal('status_foo', @seatsio.events.retrieve_object_info(key: event.key, label: 'A-2').status)
    assert_equal('free', @seatsio.events.retrieve_object_info(key: event.key, label: 'A-3').status)

    a1 = res.objects['A-1']
    assert_equal('status_foo', a1.status)
    assert_equal('A-1', a1.label)
    assert_equal({ 'own' => { 'label' => '1', 'type' => 'seat' }, 'parent' => { 'label' => 'A', 'type' => 'row' } }, a1.labels)
    assert_equal({ 'own' => '1', 'parent' => 'A' }, a1.ids)
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

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal('status_foo', object_info1.status)
    assert_nil(object_info1.hold_token)

    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-2'
    assert_equal('status_foo', object_info2.status)
    assert_nil(object_info2.hold_token)

  end

  def test_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'status_foo', order_id: 'myOrder')
    assert_equal('myOrder', @seatsio.events.retrieve_object_info(key: event.key, label: 'A-1').order_id)
    assert_equal('myOrder', @seatsio.events.retrieve_object_info(key: event.key, label: 'A-2').order_id)
  end

  def test_ticket_type
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    props1 = { :objectId => 'A-1', :ticketType => 'Ticket Type 1' }
    props2 = { :objectId => 'A-2', :ticketType => 'Ticket Type 2' }

    @seatsio.events.change_object_status(event.key, [props1, props2], 'status_foo')

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal('status_foo', object_info1.status)
    assert_equal('Ticket Type 1', object_info1.ticket_type)

    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-2'
    assert_equal('status_foo', object_info2.status)
    assert_equal('Ticket Type 2', object_info2.ticket_type)
  end

  def test_quantity
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    props1 = { :objectId => 'GA1', :quantity => 5 }
    props2 = { :objectId => 'GA2', :quantity => 10 }

    @seatsio.events.change_object_status(event.key, [props1, props2], 'status_foo')
    assert_equal(5, @seatsio.events.retrieve_object_info(key: event.key, label: 'GA1').num_booked)
    assert_equal(10, @seatsio.events.retrieve_object_info(key: event.key, label: 'GA2').num_booked)
  end

  def test_change_object_status_with_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    props1 = { :objectId => 'A-1', :extraData => { 'foo': 'bar' } }
    props2 = { :objectId => 'A-2', :extraData => { 'foo': 'baz' } }

    @seatsio.events.change_object_status(event.key, [props1, props2], 'status_foo')

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-2'

    assert_equal({ 'foo' => 'bar' }, object_info1.extra_data)
    assert_equal({ 'foo' => 'baz' }, object_info2.extra_data)
  end

  def test_keep_extra_data_true
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = { 'name' => 'John Doe' }
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_object_status(event.key, 'A-1', 'someStatus', keep_extra_data: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(extra_data, object_info.extra_data)
  end

  def test_keep_extra_data_false
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = { 'name' => 'John Doe' }
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_object_status(event.key, 'A-1', 'someStatus', keep_extra_data: false)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_nil(nil, object_info.extra_data)
  end

  def test_no_keep_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = { 'name' => 'John Doe' }
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_object_status(event.key, 'A-1', 'someStatus')

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_nil(nil, object_info.extra_data)
  end

  def test_channel_keys
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: {
      "channelKey1" => { "name" => "channel 1", "color" => "#FF0000", "index" => 1 }
    }
    @seatsio.events.channels.set_objects key: event.key, channelConfig: {
      "channelKey1" => ["A-1", "A-2"]
    }

    @seatsio.events.change_object_status(event.key, 'A-1', "someStatus", channel_keys: ["channelKey1"])

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal("someStatus", object_info.status)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: {
      "channelKey1" => { "name" => "channel 1", "color" => "#FF0000", "index" => 1 }
    }
    @seatsio.events.channels.set_objects key: event.key, channelConfig: {
      "channelKey1" => ["A-1", "A-2"]
    }

    @seatsio.events.change_object_status(event.key, 'A-1', "someStatus", ignore_channels: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal("someStatus", object_info.status)
  end

  def test_ignore_social_distancing
    chart_key = create_test_chart
    rulesets = {
      "ruleset" => {
        "name" => "ruleset",
        "fixedGroupLayout" => true,
        "disabledSeats" => ["A-1"]
      }
    }
    @seatsio.charts.save_social_distancing_rulesets(chart_key, rulesets)
    event = @seatsio.events.create chart_key: chart_key, social_distancing_ruleset_key: "ruleset"

    @seatsio.events.change_object_status(event.key, 'A-1', "someStatus", ignore_social_distancing: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal("someStatus", object_info.status)
  end

  def test_allowed_previous_statuses
    begin
      chart_key = create_test_chart
      event = @seatsio.events.create chart_key: chart_key

      @seatsio.events.change_object_status(event.key, ['A-1'], 'foo', :allowed_previous_statuses => ['someOtherStatus'])
      raise "Should have failed: expected SeatsioException"
    rescue Seatsio::Exception::SeatsioException => e
      assert_equal(400, e.message.code)
      assert_match /ILLEGAL_STATUS_CHANGE/, e.message.body
      assert_match /free is not in the list of allowed previous statuses/, e.message.body
    end
  end

  def test_rejected_previous_statuses
    begin
      chart_key = create_test_chart
      event = @seatsio.events.create chart_key: chart_key
      @seatsio.events.change_object_status(event.key, ['A-1'], 'foo', :rejected_previous_statuses => ['free'])
      raise "Should have failed: expected SeatsioException"
    rescue Seatsio::Exception::SeatsioException => e
      assert_equal(400, e.message.code)
      assert_match /ILLEGAL_STATUS_CHANGE/, e.message.body
      assert_match /free is in the list of rejected previous statuses/, e.message.body
    end
  end
end
