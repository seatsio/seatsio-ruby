require 'test_helper'
require 'util'
require 'seatsio/domain'

class BookObjectsTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_book_objects
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)

    a1_status = @seatsio.events.retrieve_object_status(event.key, 'A-1').status
    a2_status = @seatsio.events.retrieve_object_status(event.key, 'A-2').status
    a3_status = @seatsio.events.retrieve_object_status(event.key, 'A-3').status

    res = @seatsio.events.book(event.key, %w(A-1 A-2))

    a1_status = @seatsio.events.retrieve_object_status(event.key, 'A-1').status
    a2_status = @seatsio.events.retrieve_object_status(event.key, 'A-2').status
    a3_status = @seatsio.events.retrieve_object_status(event.key, 'A-3').status

    assert_equal(Seatsio::Domain::ObjectStatus::BOOKED, a1_status)
    assert_equal(Seatsio::Domain::ObjectStatus::BOOKED, a2_status)
    assert_equal(Seatsio::Domain::ObjectStatus::FREE, a3_status)

    assert_equal(res.labels, {
      'A-1' => {'own' => {'label' => '1', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}},
      'A-2' => {'own' => {'label' => '2', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}}
    })
  end

  def test_sections
    chart_key = create_test_chart_with_sections
    event = @seatsio.events.create(chart_key)

    res = @seatsio.events.book(event.key, ['Section A-A-1', 'Section A-A-2'])

    a1_status = @seatsio.events.retrieve_object_status(event.key, 'Section A-A-1').status
    a2_status = @seatsio.events.retrieve_object_status(event.key, 'Section A-A-2').status
    a3_status = @seatsio.events.retrieve_object_status(event.key, 'Section A-A-3').status

    assert_equal(Seatsio::Domain::ObjectStatus::BOOKED , a1_status)
    assert_equal(Seatsio::Domain::ObjectStatus::BOOKED , a2_status)
    assert_equal(Seatsio::Domain::ObjectStatus::FREE , a3_status)

    assert_equal({'Section A-A-1' => {'own' => {'label' => '1', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}, 'section' => 'Section A', 'entrance' => {'label' => 'Entrance 1'}},
                  'Section A-A-2' => {'own' => {'label' => '2', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}, 'section' => 'Section A', 'entrance' => {'label' => 'Entrance 1'}}
                },res.labels)
  end
end
