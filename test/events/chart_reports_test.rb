require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChartReportsTest < SeatsioTestClient
  def test_reportItemProperties
    chart_key = create_test_chart
  
    report = @seatsio.chart_reports.by_label(chart_key)

    assert_instance_of(Seatsio::Domain::ChartReport, report)

    report_item = report.items['A-1'][0]
    assert_instance_of(Seatsio::Domain::ChartReportItem, report_item)
    assert_equal('A-1', report_item.label)
    assert_equal({'own' => {'label' => '1', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}}, report_item.labels)
    assert_equal('Cat1', report_item.category_label)
    assert_equal('9', report_item.category_key)
    assert_equal('seat', report_item.object_type)
    assert_nil(report_item.section)
    assert_nil(report_item.entrance)
    assert_nil(report_item.capacity)
  end

  def test_report_item_properties_for_GA
    chart_key = create_test_chart

    report = @seatsio.chart_reports.by_label(chart_key)
    assert_instance_of(Seatsio::Domain::ChartReport, report)

    report_item = report.items['GA1'][0]
    assert_instance_of(Seatsio::Domain::ChartReportItem, report_item)
    assert_equal('GA1', report_item.label)
    assert_equal('generalAdmission', report_item.object_type)
    assert_equal('Cat1', report_item.category_label)
    assert_equal('9', report_item.category_key)
    assert_nil(report_item.section)
    assert_nil(report_item.entrance)
    assert_equal(100, report_item.capacity)
  end
  
  def test_by_label
    chart_key = create_test_chart

    report = @seatsio.chart_reports.by_label(chart_key)

    assert_instance_of(Seatsio::Domain::ChartReport, report)
    assert_equal(1, report.items['A-1'].length)
    assert_equal(1, report.items['A-2'].length)
  end
end
