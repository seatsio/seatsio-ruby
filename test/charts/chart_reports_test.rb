require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChartReportsTest < SeatsioTestClient
  def test_reportItemProperties
    chart_key = create_test_chart

    report = @seatsio.chart_reports.by_label(chart_key)

    assert_instance_of(Seatsio::ChartReport, report)

    report_item = report.items['A-1'][0]
    assert_instance_of(Seatsio::ChartReportItem, report_item)
    assert_equal('A-1', report_item.label)
    assert_equal({'own' => {'label' => '1', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}}, report_item.labels)
    assert_equal('Cat1', report_item.category_label)
    assert_equal('9', report_item.category_key)
    assert_equal('seat', report_item.object_type)
    assert_nil(report_item.section)
    assert_nil(report_item.entrance)
    assert_nil(report_item.capacity)
    assert_nil(report_item.left_neighbour)
    assert_equal('A-2', report_item.right_neighbour)
    assert_nil(report_item.book_as_a_whole)
    assert_not_nil(report_item.distance_to_focal_point)
  end

  def test_report_item_properties_for_GA
    chart_key = create_test_chart

    report = @seatsio.chart_reports.by_label(chart_key)
    assert_instance_of(Seatsio::ChartReport, report)

    report_item = report.items['GA1'][0]
    assert_instance_of(Seatsio::ChartReportItem, report_item)
    assert_equal('GA1', report_item.label)
    assert_equal('generalAdmission', report_item.object_type)
    assert_equal('Cat1', report_item.category_label)
    assert_equal('9', report_item.category_key)
    assert_nil(report_item.section)
    assert_nil(report_item.entrance)
    assert_equal(100, report_item.capacity)
    assert_false(report_item.book_as_a_whole)
  end

  def test_by_label
    chart_key = create_test_chart

    report = @seatsio.chart_reports.by_label(chart_key)

    assert_instance_of(Seatsio::ChartReport, report)
    assert_equal(1, report.items['A-1'].length)
    assert_equal(1, report.items['A-2'].length)
  end

  def test_by_label_book_whole_tables_nil
    chart_key = create_test_chart_with_tables

    report = @seatsio.chart_reports.by_label(chart_key)

    assert_instance_of(Seatsio::ChartReport, report)
    assert_equal(14, report.items.length)
  end

  def test_by_label_book_whole_tables_chart
    chart_key = create_test_chart_with_tables

    report = @seatsio.chart_reports.by_label(chart_key, 'chart')

    assert_instance_of(Seatsio::ChartReport, report)
    assert_equal(7, report.items.length)
  end

  def test_by_label_book_whole_tables_true
    chart_key = create_test_chart_with_tables

    report = @seatsio.chart_reports.by_label(chart_key, 'true')

    assert_instance_of(Seatsio::ChartReport, report)
    assert_equal(2, report.items.length)
  end

  def test_by_label_book_whole_tables_false
    chart_key = create_test_chart_with_tables

    report = @seatsio.chart_reports.by_label(chart_key, 'false')

    assert_instance_of(Seatsio::ChartReport, report)
    assert_equal(12, report.items.length)
  end

  def test_by_object_type
    chart_key = create_test_chart
    report = @seatsio.chart_reports.by_object_type(chart_key)
    assert_equal(2, report.items.length)
    assert_equal(32, report.items["seat"].length)
    assert_equal(2, report.items["generalAdmission"].length)
  end

  def test_by_category_key
    chart_key = create_test_chart
    report = @seatsio.chart_reports.by_category_key(chart_key)
    assert_equal(2, report.items.length)
    assert_equal(17, report.items["9"].length)
    assert_equal(17, report.items["10"].length)
  end

  def test_by_category_label
    chart_key = create_test_chart
    report = @seatsio.chart_reports.by_category_label(chart_key)
    assert_equal(2, report.items.length)
    assert_equal(17, report.items["Cat1"].length)
    assert_equal(17, report.items["Cat2"].length)
  end

  def test_with_extra_data
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key
    extra_data = {"foo" => "bar"}

    @seatsio.events.update_extra_data key: event1.key, object: 'A-1', extra_data: extra_data
    @seatsio.events.update_extra_data key: event2.key, object: 'A-1', extra_data: extra_data

    report = @seatsio.event_reports.by_label(event1.key)

    assert_equal(extra_data, report.items['A-1'][0].extra_data)
  end
end
