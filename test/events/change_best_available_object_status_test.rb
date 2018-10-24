require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChangeBestAvailableObjectStatusTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_number
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    result = @seatsio.events.change_best_available_object_status(event.key, 3, 'myStatus')
    assert_equal(true, result.next_to_each_other)
    assert_equal(%w(B-4 B-5 B-6), result.objects)
  end

  def test_labels
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    result = @seatsio.events.change_best_available_object_status(event.key, 2, 'myStatus')
    assert_equal({
                   'B-4' => {'own' => {'label' => '4', 'type' => 'seat'}, 'parent' => {'label' => 'B', 'type' => 'row'}},
                   'B-5' => {'own' => {'label' => '5', 'type' => 'seat'}, 'parent' => {'label' => 'B', 'type' => 'row'}}
                 }, result.labels)
  end

  def test_categories
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    result = @seatsio.events.change_best_available_object_status(event.key, 3, 'myStatus', ['cat2'])
    assert_equal(%w(C-4 C-5 C-6), result.objects)
  end

  def test_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    d1 = {'key1' => 'value1'}
    d2 = {'key2' => 'value2'}
    extra_data = [d1, d2]
    result = @seatsio.events.change_best_available_object_status(event.key, 2, 'mystatus', nil, nil, extra_data)
    assert_equal(%w(B-4 B-5), result.objects)
    assert_equal(d1, @seatsio.events.retrieve_object_status(event.key, 'B-4').extra_data)
    assert_equal(d2, @seatsio.events.retrieve_object_status(event.key, 'B-5').extra_data)
  end

  def test_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    hold_token = @seatsio.hold_tokens.create

    best_available_objects = @seatsio.events.change_best_available_object_status(event.key, 1, Seatsio::Domain::ObjectStatus::HELD, nil, hold_token.hold_token)

    object_status = @seatsio.events.retrieve_object_status(event.key, best_available_objects.objects[0])
    assert_equal(Seatsio::Domain::ObjectStatus::HELD, object_status.status)
    assert_equal(hold_token.hold_token, object_status.hold_token)
  end

  def test_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    best_available_objects = @seatsio.events.change_best_available_object_status(event.key, 1, 'mystatus', nil, nil, nil, 'anOrder')
    object_status = @seatsio.events.retrieve_object_status(event.key, best_available_objects.objects[0])
    assert_equal('anOrder', object_status.order_id)
  end

  def test_book_best_available
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)

    best_available_objects = @seatsio.events.book_best_available(event.key, 3)
    assert_equal(true, best_available_objects.next_to_each_other)
    assert_equal(%w(B-4 B-5 B-6), best_available_objects.objects)
  end

  def test_hold_best_available
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    hold_token = @seatsio.hold_tokens.create

    best_available_objects = @seatsio.events.hold_best_available(event.key, 1, nil, hold_token.hold_token)

    object_status = @seatsio.events.retrieve_object_status(event.key, best_available_objects.objects[0])
    assert_equal(Seatsio::Domain::ObjectStatus::HELD, object_status.status)
    assert_equal(hold_token.hold_token, object_status.hold_token)
  end
end