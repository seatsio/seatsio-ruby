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

    assert_instance_of(String, csv)
    assert(csv.include?('A-1'))
  end
end

