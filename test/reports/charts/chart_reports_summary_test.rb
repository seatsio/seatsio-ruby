require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/exception'

class ChartReportsSummaryTest < SeatsioTestClient
  def test_summary_by_object_type
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.summary_by_object_type(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.summary_by_object_type(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_equal(32, report['seat']['count'])
      assert_equal(32, report['seat']['bySection']['NO_SECTION'])
      assert_equal(16, report['seat']['byCategoryKey']['9'])
      assert_equal(16, report['seat']['byCategoryKey']['10'])
      assert_equal(16, report['seat']['byCategoryLabel']['Cat1'])
      assert_equal(16, report['seat']['byCategoryLabel']['Cat2'])

      assert_equal(200, report['generalAdmission']['count'])
      assert_equal(200, report['generalAdmission']['bySection']['NO_SECTION'])
      assert_equal(100, report['generalAdmission']['byCategoryKey']['9'])
      assert_equal(100, report['generalAdmission']['byCategoryKey']['10'])
      assert_equal(100, report['generalAdmission']['byCategoryLabel']['Cat1'])
      assert_equal(100, report['generalAdmission']['byCategoryLabel']['Cat2'])
    end
  end

  def test_summary_by_object_type_book_whole_tables_true
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.summary_by_object_type(chart_key, 'true') }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.summary_by_object_type(chart_key, 'true', 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_tables
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_equal(2, report['table']['count'])
      assert_equal(0, report['seat']['count'])
    end
  end

  def test_summary_by_category_key
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.summary_by_category_key(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.summary_by_category_key(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_equal(116, report['9']['count'])
      assert_equal(116, report['9']['bySection']['NO_SECTION'])
      assert_equal(16, report['9']['byObjectType']['seat'])
      assert_equal(100, report['9']['byObjectType']['generalAdmission'])

      assert_equal(116, report['10']['count'])
      assert_equal(116, report['10']['bySection']['NO_SECTION'])
      assert_equal(16, report['10']['byObjectType']['seat'])
      assert_equal(100, report['10']['byObjectType']['generalAdmission'])
    end
  end

  def test_summary_by_category_label
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.summary_by_category_label(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.summary_by_category_label(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_equal(116, report['Cat1']['count'])
      assert_equal(116, report['Cat1']['bySection']['NO_SECTION'])
      assert_equal(16, report['Cat1']['byObjectType']['seat'])
      assert_equal(100, report['Cat1']['byObjectType']['generalAdmission'])

      assert_equal(116, report['Cat2']['count'])
      assert_equal(116, report['Cat2']['bySection']['NO_SECTION'])
      assert_equal(16, report['Cat2']['byObjectType']['seat'])
      assert_equal(100, report['Cat2']['byObjectType']['generalAdmission'])
    end
  end

  def test_summary_by_section
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.summary_by_section(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.summary_by_section(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_equal(232, report['NO_SECTION']['count'])
      assert_equal(116, report['NO_SECTION']['byCategoryKey']['9'])
      assert_equal(116, report['NO_SECTION']['byCategoryKey']['10'])
      assert_equal(116, report['NO_SECTION']['byCategoryLabel']['Cat1'])
      assert_equal(116, report['NO_SECTION']['byCategoryLabel']['Cat2'])
      assert_equal(32, report['NO_SECTION']['byObjectType']['seat'])
      assert_equal(200, report['NO_SECTION']['byObjectType']['generalAdmission'])
    end
  end

  private def create_draft_version(chart_key)
    @seatsio.events.create chart_key: chart_key
    @seatsio.charts.update key: chart_key, new_name: 'foo'
  end
end
