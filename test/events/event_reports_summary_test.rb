require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/exception'

class EventReportsSummaryTest < SeatsioTestClient
  def test_summary_by_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, [{:objectId => 'A-1', :ticketType => 'tt1'}], nil, 'order1')

    report = @seatsio.event_reports.summary_by_status(event.key)

    assert_equal(1, report['booked']['count'])
    assert_equal(1, report['booked']['bySection']['NO_SECTION'])
    assert_equal(1, report['booked']['byCategoryKey']['9'])
    assert_equal(1, report['booked']['byCategoryLabel']['Cat1'])

    assert_equal(231, report['free']['count'])
    assert_equal(231, report['free']['bySection']['NO_SECTION'])
    assert_equal(115, report['free']['byCategoryKey']['9'])
    assert_equal(116, report['free']['byCategoryKey']['10'])
    assert_equal(115, report['free']['byCategoryLabel']['Cat1'])
    assert_equal(116, report['free']['byCategoryLabel']['Cat2'])
  end

  def test_summary_by_category_key
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, [{:objectId => 'A-1', :ticketType => 'tt1'}], nil, 'order1')

    report = @seatsio.event_reports.summary_by_category_key(event.key)

    assert_equal(116, report['9']['count'])
    assert_equal(116, report['9']['bySection']['NO_SECTION'])
    assert_equal(1, report['9']['byStatus']['booked'])
    assert_equal(115, report['9']['byStatus']['free'])

    assert_equal(116, report['10']['count'])
    assert_equal(116, report['10']['bySection']['NO_SECTION'])
    assert_equal(116, report['10']['byStatus']['free'])
  end

  def test_summary_by_category_label
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, [{:objectId => 'A-1', :ticketType => 'tt1'}], nil, 'order1')

    report = @seatsio.event_reports.summary_by_category_label(event.key)

    assert_equal(116, report['Cat1']['count'])
    assert_equal(116, report['Cat1']['bySection']['NO_SECTION'])
    assert_equal(1, report['Cat1']['byStatus']['booked'])
    assert_equal(115, report['Cat1']['byStatus']['free'])

    assert_equal(116, report['Cat2']['count'])
    assert_equal(116, report['Cat2']['bySection']['NO_SECTION'])
    assert_equal(116, report['Cat2']['byStatus']['free'])
  end

  def test_summary_by_section
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, [{:objectId => 'A-1', :ticketType => 'tt1'}], nil, 'order1')

    report = @seatsio.event_reports.summary_by_section(event.key)

    assert_equal(232, report['NO_SECTION']['count'])
    assert_equal(1, report['NO_SECTION']['byStatus']['booked'])
    assert_equal(231, report['NO_SECTION']['byStatus']['free'])
    assert_equal(116, report['NO_SECTION']['byCategoryKey']['9'])
    assert_equal(116, report['NO_SECTION']['byCategoryKey']['10'])
    assert_equal(116, report['NO_SECTION']['byCategoryLabel']['Cat1'])
    assert_equal(116, report['NO_SECTION']['byCategoryLabel']['Cat2'])
  end
end
