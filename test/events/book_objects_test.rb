require 'test_helper'
require 'util'
require 'seatsio/domain'

class BookObjectsTest < SeatsioTestClient
  def test_book_objects
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    a1_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-1').status
    a2_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-2').status
    a3_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-3').status

    res = @seatsio.events.book(event.key, %w(A-1 A-2))

    a1_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-1').status
    a2_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-2').status
    a3_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-3').status

    assert_equal(Seatsio::EventObjectInfo::BOOKED, a1_status)
    assert_equal(Seatsio::EventObjectInfo::BOOKED, a2_status)
    assert_equal(Seatsio::EventObjectInfo::FREE, a3_status)

    assert_equal(res.objects.keys.sort, ['A-1', 'A-2'])
  end

  def test_sections
    chart_key = create_test_chart_with_sections
    event = @seatsio.events.create chart_key: chart_key

    res = @seatsio.events.book(event.key, ['Section A-A-1', 'Section A-A-2'])

    a1_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'Section A-A-1').status
    a2_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'Section A-A-2').status
    a3_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'Section A-A-3').status

    assert_equal(Seatsio::EventObjectInfo::BOOKED, a1_status)
    assert_equal(Seatsio::EventObjectInfo::BOOKED, a2_status)
    assert_equal(Seatsio::EventObjectInfo::FREE, a3_status)

    seat_a1 = res.objects['Section A-A-1']
    assert_equal("Section A", seat_a1.section)
    assert_equal("Entrance 1", seat_a1.entrance)
    assert_equal(
      { 'own' => { 'label' => '1', 'type' => 'seat' }, 'parent' => { 'label' => 'A', 'type' => 'row' }, 'section' => 'Section A', 'entrance' => { 'label' => 'Entrance 1' } },
      seat_a1.labels
    )
    assert_equal(
      { 'own' => '1', 'parent' => 'A', 'section' => 'Section A' },
      seat_a1.ids
    )
  end

  def test_with_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token)

    @seatsio.events.book(event.key, %w(A-1 A-2), hold_token: hold_token.hold_token)

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::BOOKED, object_info1.status)
    assert_nil(object_info1.hold_token)

    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-2'
    assert_equal(Seatsio::EventObjectInfo::BOOKED, object_info2.status)
    assert_nil(object_info2.hold_token)
  end

  def test_with_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, %w(A-1 A-2), order_id: 'order1')

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal('order1', object_info1.order_id)

    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-2'
    assert_equal('order1', object_info2.order_id)
  end

  def test_book_with_properties
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    objects = [
      { :objectId => 'A-5', :extraData => { 'name' => 'John Doe' } },
      { :objectId => 'A-6', :extraData => { 'name' => 'John Doe' } }
    ]

    @seatsio.events.book(event.key, objects)

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-5'
    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-6'
    assert_equal('booked', object_info1.status)
    assert_equal('booked', object_info2.status)
  end

  def test_keep_extra_data_true
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = { 'name' => 'John Doe' }
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    @seatsio.events.book(event.key, 'A-1', keep_extra_data: true)

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

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::BOOKED, object_info.status)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: [
      { "key" => "channelKey1", "name" => "channel 1", "color" => "#FF0000", "index" => 1, "objects" => %w[A-1 A-2] }
    ]

    @seatsio.events.book(event.key, 'A-1', ignore_channels: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::BOOKED, object_info.status)
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

    @seatsio.events.book(event.key, 'A-1', ignore_social_distancing: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::BOOKED, object_info.status)
  end
end
