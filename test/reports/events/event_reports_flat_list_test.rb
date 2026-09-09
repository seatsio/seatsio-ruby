require 'test_helper'
require 'util'
require 'seatsio/domain'

class EventReportsFlatListTest < SeatsioTestClient
  def test_flat_list
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.flat_list(event.key)

    assert_equal(34, report.length)
    assert_instance_of(Seatsio::EventObjectInfo, report[0])
    assert_equal('A-1', report[0].label)
  end

  def test_flat_list_is_sorted_by_label
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.flat_list(event.key)

    labels = report.map(&:label)
    assert_equal(labels.sort, labels)
  end

  def test_flat_list_csv
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    csv = @seatsio.event_reports.flat_list_csv(event.key)

    assert_kind_of(String, csv)
    assert(csv.include?('A-1'))
  end

  def test_flat_list_with_season_bookings_not_propagated
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key, number_of_events: 1
    event = season.events[0]
    @seatsio.events.book(season.key, %w(A-1 A-2))
    @seatsio.events.book(event.key, ['A-3'])

    report_with_propagation = @seatsio.event_reports.flat_list(season.key)
    report_without_propagation = @seatsio.event_reports.with_season_bookings_not_propagated.flat_list(season.key)

    a3_with_propagation = report_with_propagation.find { |item| item.label == 'A-3' }
    a3_without_propagation = report_without_propagation.find { |item| item.label == 'A-3' }

    assert_equal(Seatsio::EventObjectInfo::BOOKED, a3_with_propagation.status)
    refute_equal(Seatsio::EventObjectInfo::BOOKED, a3_without_propagation.status)
  end
end

