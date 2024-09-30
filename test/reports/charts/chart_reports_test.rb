require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChartReportsTest < SeatsioTestClient
  def test_reportItemProperties
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_instance_of(Seatsio::ChartReport, report)

      report_item = report.items['A-1'][0]
      assert_instance_of(Seatsio::ChartObjectInfo, report_item)
      assert_equal('A-1', report_item.label)
      assert_equal({'own' => {'label' => '1', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}}, report_item.labels)
      assert_equal({'own' => '1', 'parent' => 'A'}, report_item.ids)
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
      assert_not_nil(report_item.is_accessible)
      assert_not_nil(report_item.is_companion_seat)
      assert_not_nil(report_item.has_restricted_view)
      assert_nil(report_item.floor)
    end
  end

  def test_report_item_properties_for_GA
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_instance_of(Seatsio::ChartReport, report)

      report_item = report.items['GA1'][0]
      assert_instance_of(Seatsio::ChartObjectInfo, report_item)
      assert_equal('GA1', report_item.label)
      assert_equal('generalAdmission', report_item.object_type)
      assert_equal('Cat1', report_item.category_label)
      assert_equal('9', report_item.category_key)
      assert_nil(report_item.section)
      assert_nil(report_item.entrance)
      assert_equal(100, report_item.capacity)
      assert_false(report_item.book_as_a_whole)
    end
  end

  def test_report_item_properties_for_table
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, 'true') }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, 'true', 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_tables
      update_chart.(chart_key)

      report = get_report.(chart_key)

      report_item = report.items['T1'][0]
      assert_equal(6, report_item.num_seats)
      assert_equal(false, report_item.book_as_a_whole)
    end
  end

  def test_by_label
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_instance_of(Seatsio::ChartReport, report)
      assert_equal(1, report.items['A-1'].length)
      assert_equal(1, report.items['A-2'].length)
    end
  end

  def test_by_label_with_floors
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_floors
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_instance_of(Seatsio::ChartReport, report)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['S1-A-1'][0].floor)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['S1-A-2'][0].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['S2-B-1'][0].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['S2-B-1'][0].floor)
    end
  end

  def test_by_label_book_whole_tables_nil
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_tables
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_instance_of(Seatsio::ChartReport, report)
      assert_equal(14, report.items.length)
    end
  end

  def test_by_label_book_whole_tables_chart
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, 'chart') }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, 'chart', 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_tables
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_instance_of(Seatsio::ChartReport, report)
      assert_equal(7, report.items.length)
    end
  end

  def test_by_label_book_whole_tables_true
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, 'true') }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, 'true', 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_tables
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_instance_of(Seatsio::ChartReport, report)
      assert_equal(2, report.items.length)
    end
  end

  def test_by_label_book_whole_tables_false
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, 'false') }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_label(chart_key, 'false', 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_tables
      update_chart.(chart_key)

      report = get_report.(chart_key)

      assert_instance_of(Seatsio::ChartReport, report)
      assert_equal(12, report.items.length)
    end
  end

  def test_by_object_type
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_object_type(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_object_type(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal(4, report.items.length)
      assert_equal(32, report.items['seat'].length)
      assert_equal(2, report.items['generalAdmission'].length)
      assert_equal(0, report.items['booth'].length)
      assert_equal(0, report.items['table'].length)
    end
  end

  def test_by_object_type_with_floors
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_object_type(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_object_type(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_floors
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['seat'][0].floor)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['seat'][1].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['seat'][2].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['seat'][3].floor)

    end
  end

  def test_by_category_key
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_category_key(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_category_key(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal(4, report.items.length)
      assert_equal(17, report.items['9'].length)
      assert_equal(17, report.items['10'].length)
      assert_equal(0, report.items['string11'].length)
      assert_equal(0, report.items['NO_CATEGORY'].length)
    end
  end

  def test_by_category_key_with_floors
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_category_key(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_category_key(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_floors
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['1'][0].floor)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['1'][1].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['2'][0].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['2'][1].floor)
    end
  end

  def test_by_category_label
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_category_label(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_category_label(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal(4, report.items.length)
      assert_equal(17, report.items['Cat1'].length)
      assert_equal(17, report.items['Cat2'].length)
      assert_equal(0, report.items['Cat3'].length)
      assert_equal(0, report.items['NO_CATEGORY'].length)
    end
  end

  def test_by_category_label_with_floors
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_category_label(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_category_label(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_floors
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['CatA'][0].floor)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['CatA'][1].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['CatB'][0].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['CatB'][1].floor)
    end
  end

  def test_by_section
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_section(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_section(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_sections
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal(3, report.items.length)
      assert_equal(36, report.items['Section A'].length)
      assert_equal(35, report.items['Section B'].length)
      assert_equal(0, report.items['NO_SECTION'].length)
    end
  end

  def test_by_section_with_floors
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_section(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_section(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_floors
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['S1'][0].floor)
      assert_equal({'name' => '1', 'displayName' => 'Floor 1'}, report.items['S1'][1].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['S2'][0].floor)
      assert_equal({'name' => '2', 'displayName' => 'Floor 2'}, report.items['S2'][1].floor)
    end
  end

  def test_by_zone
    [
      [-> (_) { }, -> (chart_key) { @seatsio.chart_reports.by_zone(chart_key) }],
      [-> (chart_key) { create_draft_version chart_key }, -> (chart_key) { @seatsio.chart_reports.by_zone(chart_key, nil, 'draft') }]
    ].each do |update_chart, get_report|
      chart_key = create_test_chart_with_zones
      update_chart.(chart_key)

      report = get_report.(chart_key)
      assert_equal(3, report.items.length)
      assert_equal(6032, report.items['midtrack'].length)
      assert_equal('midtrack', report.items['midtrack'][0].zone)
      assert_equal(2865, report.items['finishline'].length)
      assert_equal(0, report.items['NO_ZONE'].length)
    end
  end

  def test_with_extra_data
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key
    extra_data = {'foo' => 'bar'}

    @seatsio.events.update_extra_data key: event1.key, object: 'A-1', extra_data: extra_data
    @seatsio.events.update_extra_data key: event2.key, object: 'A-1', extra_data: extra_data

    report = @seatsio.event_reports.by_label(event1.key)

    assert_equal(extra_data, report.items['A-1'][0].extra_data)
  end

  private def create_draft_version(chart_key)
    @seatsio.events.create chart_key: chart_key
    @seatsio.charts.update key: chart_key, new_name: 'foo'
  end
end
