require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/exception'

class EventReportsTest < SeatsioTestClient
  def test_report_instances
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = { 'foo' => 'bar' }

    @seatsio.events.book(event.key, [{ :objectId => 'A-1', :ticketType => 'tt1', :extraData => extra_data }], order_id: 'order1')

    report = @seatsio.event_reports.by_label(event.key)
    report_item = report.items['A-1'][0]

    assert_instance_of(Seatsio::EventReport, report)
    assert_instance_of(Seatsio::EventObjectInfo, report_item)
  end

  def test_report_item_properties
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = { 'foo' => 'bar' }

    @seatsio.events.book(event.key, [{ :objectId => 'A-1', :ticketType => 'tt1', :extraData => extra_data }], order_id: 'order1')

    @seatsio.events.channels.replace key: event.key, channels: [
      { "key" => "channelKey1", "name" => "channel 1", "color" => "#FF0000", "index" => 1, "objects" => %w[A-1] }
    ]

    report = @seatsio.event_reports.by_label(event.key)

    report_item = report.items['A-1'][0]

    assert_equal('booked', report_item.status)
    assert_equal('A-1', report_item.label)
    assert_equal({ 'own' => { 'label' => '1', 'type' => 'seat' }, 'parent' => { 'label' => 'A', 'type' => 'row' } }, report_item.labels)
    assert_equal({ 'own' => '1', 'parent' => 'A' }, report_item.ids)
    assert_equal('Cat1', report_item.category_label)
    assert_equal('9', report_item.category_key)
    assert_equal('tt1', report_item.ticket_type)
    assert_equal('order1', report_item.order_id)
    assert_equal('seat', report_item.object_type)
    assert_equal(true, report_item.for_sale)
    assert_nil(report_item.section)
    assert_nil(report_item.entrance)
    assert_nil(report_item.num_booked)
    assert_nil(report_item.capacity)
    assert_nil(report_item.book_as_a_whole)
    assert_equal(extra_data, report_item.extra_data)
    assert_false(report_item.is_accessible)
    assert_false(report_item.is_companion_seat)
    assert_false(report_item.has_restricted_view)
    assert_nil(report_item.displayed_object_type)
    assert_nil(report_item.left_neighbour)
    assert_equal('A-2', report_item.right_neighbour)
    assert_false(report_item.is_available)
    assert_equal('channelKey1', report_item.channel)
    assert_not_nil(report_item.distance_to_focal_point)

    ga_item = report.items['GA1'][0]
    assert_true(ga_item.variable_occupancy)
    assert_equal(1, ga_item.min_occupancy)
    assert_equal(100, ga_item.max_occupancy)
  end

  def test_hold_token
    chart_key = create_test_chart
    hold_token = @seatsio.hold_tokens.create
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.hold(event.key, 'A-1', hold_token.hold_token)

    report = @seatsio.event_reports.by_label(event.key)

    report_item = report.items['A-1'][0]
    assert_equal(hold_token.hold_token, report_item.hold_token)
  end

  def test_report_item_properties_for_GA
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, [{ :objectId => 'GA1', :quantity => 5 }])
    holdToken = @seatsio.hold_tokens.create
    @seatsio.events.hold(event.key, [{ :objectId => 'GA1', :quantity => 3 }], holdToken.hold_token)

    report = @seatsio.event_reports.by_label(event.key)

    report_item = report.items['GA1'][0]
    assert_equal('free', report_item.status)
    assert_equal('GA1', report_item.label)
    assert_equal('generalAdmission', report_item.object_type)
    assert_equal('Cat1', report_item.category_label)
    assert_equal('9', report_item.category_key)
    assert_nil(report_item.ticket_type)
    assert_nil(report_item.order_id)
    assert(true, report_item.for_sale)
    assert_nil(report_item.section)
    assert_nil(report_item.entrance)
    assert_equal(5, report_item.num_booked)
    assert_equal(92, report_item.num_free)
    assert_equal(3, report_item.num_held)
    assert_equal(100, report_item.capacity)
    assert_false(report_item.book_as_a_whole)
    assert_nil(report_item.is_accessible)
    assert_nil(report_item.is_companion_seat)
    assert_nil(report_item.has_restricted_view)
    assert_nil(report_item.displayed_object_type)
  end

  def test_report_item_properties_for_table
    chart_key = create_test_chart_with_tables
    event = @seatsio.events.create chart_key: chart_key, table_booking_config: Seatsio::TableBookingConfig::all_by_table()

    report = @seatsio.event_reports.by_label(event.key)

    report_item = report.items['T1'][0]
    assert_equal(6, report_item.num_seats)
    assert_false(report_item.book_as_a_whole)
  end

  def test_by_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'mystatus')
    @seatsio.events.change_object_status(event.key, ['A-3'], 'booked')

    report = @seatsio.event_reports.by_status(event.key)

    assert_equal(2, report.items['mystatus'].length)
    assert_equal(1, report.items['booked'].length)
    assert_equal(31, report.items['free'].length)
  end

  def test_by_object_type
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_object_type(event.key)

    assert_equal(32, report.items['seat'].length)
    assert_equal(2, report.items['generalAdmission'].length)
    assert_equal(0, report.items['booth'].length)
    assert_equal(0, report.items['table'].length)
  end

  def test_by_status_empty_chart
    chart_key = @seatsio.charts.create.key
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_status(event.key)

    assert_equal(0, report.items.length)
  end

  def test_by_specific_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.change_object_status(event.key, %w(A-1 A-2), 'mystatus')
    @seatsio.events.change_object_status(event.key, ['A-3'], 'booked')

    report = @seatsio.event_reports.by_status(event.key, 'mystatus')

    assert_equal(2, report.items.length)
  end

  def test_by_missing_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_status(event.key, 'mystatus')

    assert_equal(0, report.items.length)
  end

  def test_by_category_label
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_category_label(event.key)

    assert_equal(17, report.items['Cat1'].length)
    assert_equal(17, report.items['Cat2'].length)
  end

  def test_by_specific_category_label
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_category_label(event.key, 'Cat1')

    assert_equal(17, report.items.length)
  end

  def test_by_category_key
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_category_key(event.key)

    assert_equal(17, report.items['9'].length)
    assert_equal(17, report.items['10'].length)
  end

  def test_by_specific_category_key
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_category_key(event.key, '9')

    assert_equal(17, report.items.length)
  end

  def test_by_label
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_label(event.key)

    assert_equal(1, report.items['A-1'].length)
    assert_equal(1, report.items['A-2'].length)
  end

  def test_by_specific_label
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_label(event.key, 'A-1')

    assert_equal(1, report.items.length)
  end

  def test_by_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, %w(A-1 A-2), order_id: 'order1')
    @seatsio.events.book(event.key, ['A-3'], order_id: 'order2')

    report = @seatsio.event_reports.by_order_id(event.key)

    assert_equal(2, report.items['order1'].length)
    assert_equal(1, report.items['order2'].length)
    assert_equal(31, report.items['NO_ORDER_ID'].length)
  end

  def test_by_specific_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, %w(A-1 A-2), order_id: 'order1')
    @seatsio.events.book(event.key, ['A-3'], order_id: 'order2')

    report = @seatsio.event_reports.by_order_id(event.key, 'order1')

    assert_equal(2, report.items.length)
  end

  def test_by_section
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_section(event.key)

    assert_equal(34, report.items['NO_SECTION'].length)
  end

  def test_by_specific_section
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_section(event.key, 'NO_SECTION')

    assert_equal(34, report.items.length)
  end

  def test_by_availability
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, %w(A-1 A-2))

    report = @seatsio.event_reports.by_availability(event.key)

    assert_equal(32, report.items['available'].length)
    assert_equal(2, report.items['not_available'].length)
  end

  def test_by_specific_availability
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_availability(event.key, 'available')

    assert_equal(34, report.items.length)
  end

  def test_by_availability_reason
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, %w(A-1 A-2))

    report = @seatsio.event_reports.by_availability_reason(event.key)

    assert_equal(32, report.items['available'].length)
    assert_equal(2, report.items['booked'].length)
  end

  def test_by_specific_availability_reason
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.by_availability_reason(event.key, 'available')

    assert_equal(34, report.items.length)
  end

  def test_by_channel
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: [
      { "key" => "channelKey1", "name" => "channel 1", "color" => "#FF0000", "index" => 1, "objects" => %w[A-1 A-2] }
    ]

    report = @seatsio.event_reports.by_channel(event.key)

    assert_equal(32, report.items['NO_CHANNEL'].length)
    assert_equal(2, report.items['channelKey1'].length)
  end

  def test_by_specific_channel
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: [
      { "key" => "channelKey1", "name" => "channel 1", "color" => "#FF0000", "index" => 1, "objects" => %w[A-1 A-2] }
    ]

    report = @seatsio.event_reports.by_channel(event.key, 'channelKey1')

    assert_equal(2, report.items.length)
  end
end
