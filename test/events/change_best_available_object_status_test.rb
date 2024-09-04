require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChangeBestAvailableObjectStatusTest < SeatsioTestClient
  def test_number
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    result = @seatsio.events.change_best_available_object_status(event.key, 3, 'myStatus')
    assert_equal(true, result.next_to_each_other)
    assert_equal(%w(A-4 A-5 A-6), result.objects)
  end

  def test_object_details
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    result = @seatsio.events.change_best_available_object_status(event.key, 1, 'myStatus')

    b5 = result.object_details['A-5']
    assert_equal('myStatus', b5.status)
    assert_equal('A-5', b5.label)
    assert_equal({'own' => {'label' => '5', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}}, b5.labels)
    assert_equal({'own' => '5', 'parent' => 'A'}, b5.ids)
    assert_equal('Cat1', b5.category_label)
    assert_equal('9', b5.category_key)
    assert_nil(b5.ticket_type)
    assert_nil(b5.order_id)
    assert_equal('seat', b5.object_type)
    assert_equal(true, b5.for_sale)
    assert_nil(b5.section)
    assert_nil(b5.entrance)
    assert_nil(b5.num_booked)
    assert_nil(b5.capacity)
    assert_equal('A-4', b5.left_neighbour)
    assert_equal('A-6', b5.right_neighbour)
  end

  def test_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    result = @seatsio.events.change_best_available_object_status(event.key, 3, 'myStatus', categories: ['cat2'])
    assert_equal(%w(C-4 C-5 C-6), result.objects)
  end

  def test_zone
    chart_key = create_test_chart_with_zones
    event = @seatsio.events.create chart_key: chart_key

    result_midtrack = @seatsio.events.change_best_available_object_status(event.key, 1, 'myStatus', zone: 'midtrack')
    assert_equal(%w(MT3-A-139), result_midtrack.objects)

    result_finishline = @seatsio.events.change_best_available_object_status(event.key, 1, 'myStatus', zone: 'finishline')
    assert_equal(['Goal Stand 4-A-1'], result_finishline.objects)
  end

  def test_change_best_available_object_status_with_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    d1 = {'key1' => 'value1'}
    d2 = {'key2' => 'value2'}
    extra_data = [d1, d2]
    result = @seatsio.events.change_best_available_object_status(event.key, 2, 'mystatus', extra_data: extra_data)
    assert_equal(%w(A-4 A-5), result.objects)
    assert_equal(d1, @seatsio.events.retrieve_object_info(key: event.key, label: 'A-4').extra_data)
    assert_equal(d2, @seatsio.events.retrieve_object_info(key: event.key, label: 'A-5').extra_data)
  end

  def test_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    best_available_objects = @seatsio.events.change_best_available_object_status(event.key, 1, Seatsio::EventObjectInfo::HELD, hold_token: hold_token.hold_token)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: best_available_objects.objects[0]
    assert_equal(Seatsio::EventObjectInfo::HELD, object_info.status)
    assert_equal(hold_token.hold_token, object_info.hold_token)
  end

  def test_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    best_available_objects = @seatsio.events.change_best_available_object_status(event.key, 1, 'mystatus', order_id: 'anOrder')
    object_info = @seatsio.events.retrieve_object_info key: event.key, label: best_available_objects.objects[0]
    assert_equal('anOrder', object_info.order_id)
  end

  def test_book_best_available
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    best_available_objects = @seatsio.events.book_best_available(event.key, 3)
    assert_equal(true, best_available_objects.next_to_each_other)
    assert_equal(%w(A-4 A-5 A-6), best_available_objects.objects)
  end

  def test_book_best_available_with_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = [{ name: 'John Doe'}, { name: 'Jane Doe'}, { name: 'Random person'}]

    best_available_objects = @seatsio.events.book_best_available(event.key, 3, extra_data: extra_data)
    assert_equal(true, best_available_objects.next_to_each_other)
    assert_equal(%w(A-4 A-5 A-6), best_available_objects.objects)
  end

  def test_hold_best_available
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    best_available_objects = @seatsio.events.hold_best_available(event.key, 1, hold_token.hold_token)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: best_available_objects.objects[0]
    assert_equal(Seatsio::EventObjectInfo::HELD, object_info.status)
    assert_equal(hold_token.hold_token, object_info.hold_token)
  end

  def test_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    best_available_objects = @seatsio.events.change_best_available_object_status(event.key, 1, 'someStatus', extra_data: [{ "name" => 'John Doe'}])

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: best_available_objects.objects[0]
    assert_equal({ "name" => 'John Doe'}, object_info.extra_data)
  end

  def test_do_not_try_to_prevent_orphan_seats
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, %w[A-4 A-5])

    best_available_objects = @seatsio.events.change_best_available_object_status(event.key, 2, 'someStatus', try_to_prevent_orphan_seats: false)

    assert_equal(%w(A-2 A-3), best_available_objects.objects)
  end

  def test_ticket_types
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    best_available_objects = @seatsio.events.change_best_available_object_status(event.key, 2, 'someStatus', ticket_types: ['adult', 'child'])

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: best_available_objects.objects[0]
    assert_equal('adult', object_info1.ticket_type)
    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: best_available_objects.objects[1]
    assert_equal('child', object_info2.ticket_type)
  end

  def test_keep_extra_data_true
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_best_available_object_status(event.key, 1, 'someStatus', keep_extra_data: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(extra_data, object_info.extra_data)
  end

  def test_keep_extra_data_false
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_best_available_object_status(event.key, 1, 'someStatus', keep_extra_data: false)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_nil(nil, object_info.extra_data)
  end

  def test_no_keep_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.change_best_available_object_status(event.key, 1, 'someStatus')

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_nil(nil, object_info.extra_data)
  end

  def test_channel_keys
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, channels: [
      Seatsio::Channel.new("channelKey1", "channel 1", "#FF0000", 1, %w[A-6])
    ]

    result = @seatsio.events.change_best_available_object_status(event.key, 1, 'myStatus', channel_keys: ["channelKey1"])

    assert_equal(%w(A-6), result.objects)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, channels: [
      Seatsio::Channel.new("channelKey1", "channel 1", "#FF0000", 1, %w[A-5])
    ]

    result = @seatsio.events.change_best_available_object_status(event.key, 1, 'myStatus', ignore_channels: true)

    assert_equal(%w(A-5), result.objects)
  end

  def test_accessible_seats
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    result = @seatsio.events.change_best_available_object_status(event.key, 3, 'myStatus', accessible_seats: 1)
    assert_equal(true, result.next_to_each_other)
    assert_equal(%w(A-6 A-7 A-8), result.objects)
  end
end
