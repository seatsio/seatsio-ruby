require 'test_helper'
require 'util'

class ListPageOfChartsBeforeTest < SeatsioTestClient
  def test_with_previous_page
    chart1 = @seatsio.charts.create
    chart2 = @seatsio.charts.create
    chart3 = @seatsio.charts.create

    charts = @seatsio.charts.list.page_before(chart1.id)
    charts_ids = charts.collect {|chart| chart.id}
    
    assert_equal([chart3.id, chart2.id], charts_ids)
    assert_equal(chart2.id, charts.next_page_starts_after)
    assert_nil(charts.previous_page_ends_before)
  end

  def test_with_next_and_previous_page
    chart1 = @seatsio.charts.create
    chart2 = @seatsio.charts.create
    chart3 = @seatsio.charts.create

    charts = @seatsio.charts.list.page_before(chart1.id, page_size=1)
    charts_ids = charts.collect {|chart| chart.id}

    assert_equal([chart2.id], charts_ids)
    assert_equal(chart2.id, charts.next_page_starts_after)
    assert_equal(chart2.id, charts.previous_page_ends_before)
  end
end
