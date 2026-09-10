require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/exception'

class EventReportsDeepSummaryTest < SeatsioTestClient
  def test_with_season_bookings_not_propagated_can_be_used_to_fetch_a_report_for_an_event_in_a_season
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key, number_of_events: 1
    event = season.events[0]
    @seatsio.events.book(season.key, %w(A-1 A-2))

    report = @seatsio.event_reports.with_season_bookings_not_propagated.deep_summary_by_status(event.key)

    assert_equal(232, report['free']['count'])
  end

  def test_deep_summary_by_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.deep_summary_by_status(event.key)

    assert_equal(1, report['booked']['count'])
    assert_equal(1, report['booked']['bySection']['NO_SECTION']['count'])
    assert_equal(1, report['booked']['bySection']['NO_SECTION']['byAvailability']['not_available'])
  end

  def test_deep_summary_by_object_type
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.deep_summary_by_object_type(event.key)

    assert_equal(32, report['seat']['count'])
    assert_equal(32, report['seat']['bySection']['NO_SECTION']['count'])
    assert_equal(32, report['seat']['bySection']['NO_SECTION']['byAvailability']['available'])
  end

  def test_deep_summary_by_category_key
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.deep_summary_by_category_key(event.key)

    assert_equal(116, report['9']['count'])
    assert_equal(116, report['9']['bySection']['NO_SECTION']['count'])
    assert_equal(1, report['9']['bySection']['NO_SECTION']['byAvailability']['not_available'])
  end

  def test_deep_summary_by_category_label
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.deep_summary_by_category_label(event.key)

    assert_equal(116, report['Cat1']['count'])
    assert_equal(116, report['Cat1']['bySection']['NO_SECTION']['count'])
    assert_equal(1, report['Cat1']['bySection']['NO_SECTION']['byAvailability']['not_available'])
  end

  def test_deep_summary_by_section
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.deep_summary_by_section(event.key)

    assert_equal(232, report['NO_SECTION']['count'])
    assert_equal(116, report['NO_SECTION']['byCategoryLabel']['Cat1']['count'])
    assert_equal(1, report['NO_SECTION']['byCategoryLabel']['Cat1']['byAvailability']['not_available'])
  end

  def test_deep_summary_by_zone
    chart_key = create_test_chart_with_zones
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.deep_summary_by_zone(event.key)

    assert_equal(6032, report['midtrack']['count'])
    assert_equal(6032, report['midtrack']['byCategoryLabel']['Mid Track Stand']['count'])
  end

  def test_deep_summary_by_availability
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.deep_summary_by_availability(event.key)

    assert_equal(1, report['not_available']['count'])
    assert_equal(1, report['not_available']['byCategoryLabel']['Cat1']['count'])
    assert_equal(1, report['not_available']['byCategoryLabel']['Cat1']['bySection']['NO_SECTION'])
  end

  def test_deep_summary_by_availability_reason
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.deep_summary_by_availability_reason(event.key)

    assert_equal(1, report['booked']['count'])
    assert_equal(1, report['booked']['byCategoryLabel']['Cat1']['count'])
    assert_equal(1, report['booked']['byCategoryLabel']['Cat1']['bySection']['NO_SECTION'])
  end

  def test_deep_summary_by_channel
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.deep_summary_by_channel(event.key)

    assert_equal(232, report['NO_CHANNEL']['count'])
    assert_equal(116, report['NO_CHANNEL']['byCategoryLabel']['Cat1']['count'])
    assert_equal(116, report['NO_CHANNEL']['byCategoryLabel']['Cat1']['bySection']['NO_SECTION'])
  end
end
