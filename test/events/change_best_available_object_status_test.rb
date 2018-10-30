require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChangeBestAvailableObjectStatusTest < SeatsioTestClient
  def test_number
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    result = @seatsio.events.change_best_available_object_status(key: event.key, number: 3, status: 'myStatus')
    assert_equal(true, result.next_to_each_other)
    assert_equal(%w(B-4 B-5 B-6), result.objects)
  end

  def test_labels
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    result = @seatsio.events.change_best_available_object_status(key: event.key, number: 2, status: 'myStatus')
    assert_equal({
                   'B-4' => {'own' => {'label' => '4', 'type' => 'seat'}, 'parent' => {'label' => 'B', 'type' => 'row'}},
                   'B-5' => {'own' => {'label' => '5', 'type' => 'seat'}, 'parent' => {'label' => 'B', 'type' => 'row'}}
                 }, result.labels)
  end

  def test_categories
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    result = @seatsio.events.change_best_available_object_status(key: event.key, number: 3,
                                                                 status: 'myStatus', categories: ['cat2'])
    assert_equal(%w(C-4 C-5 C-6), result.objects)
  end

  def test_change_best_available_object_status_with_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    d1 = {'key1' => 'value1'}
    d2 = {'key2' => 'value2'}
    extra_data = [d1, d2]
    result = @seatsio.events.change_best_available_object_status(key: event.key, number: 2,
                                                                 status: 'mystatus', extra_data: extra_data)
    assert_equal(%w(B-4 B-5), result.objects)
    assert_equal(d1, @seatsio.events.retrieve_object_status(key: event.key, object_key: 'B-4').extra_data)
    assert_equal(d2, @seatsio.events.retrieve_object_status(key: event.key, object_key: 'B-5').extra_data)
  end

  def test_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    hold_token = @seatsio.hold_tokens.create

    best_available_objects = @seatsio.events.change_best_available_object_status(key: event.key, number: 1,
                                                                                 status: Seatsio::Domain::ObjectStatus::HELD,
                                                                                 hold_token: hold_token.hold_token)

    object_status = @seatsio.events.retrieve_object_status key: event.key, object_key: best_available_objects.objects[0]
    assert_equal(Seatsio::Domain::ObjectStatus::HELD, object_status.status)
    assert_equal(hold_token.hold_token, object_status.hold_token)
  end

  def test_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    best_available_objects = @seatsio.events.change_best_available_object_status(key: event.key, number: 1, status: 'mystatus', order_id: 'anOrder')
    object_status = @seatsio.events.retrieve_object_status key: event.key, object_key: best_available_objects.objects[0]
    assert_equal('anOrder', object_status.order_id)
  end

  def test_book_best_available
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key

    best_available_objects = @seatsio.events.book_best_available key: event.key, number: 3
    assert_equal(true, best_available_objects.next_to_each_other)
    assert_equal(%w(B-4 B-5 B-6), best_available_objects.objects)
  end

  def test_hold_best_available
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    hold_token = @seatsio.hold_tokens.create

    best_available_objects = @seatsio.events.hold_best_available key: event.key, number: 1, hold_token: hold_token.hold_token

    object_status = @seatsio.events.retrieve_object_status key: event.key, object_key: best_available_objects.objects[0]
    assert_equal(Seatsio::Domain::ObjectStatus::HELD, object_status.status)
    assert_equal(hold_token.hold_token, object_status.hold_token)
  end
end
