require 'test_helper'
require 'util'

class ListFirstPageOfChartsTest < SeatsioTestClient
  def test_all_on_first_page
    chart1 = @seatsio.charts.create
    chart2 = @seatsio.charts.create
    chart3 = @seatsio.charts.create

    charts = @seatsio.charts.list
    # charts.set_query_param('limit', 2)

    keys = charts.first_page.collect {|chart| chart.id}

    assert_equal([chart3.id, chart2.id, chart1.id], keys)
    #assert_that(charts.items).extracting("id").contains_exactly(chart3.id, chart2.id, chart1.id)
    #assert_that(charts.next_page_starts_after).is_none()
    #assert_that(charts.previous_page_ends_before).is_none()
  end
  
  def test_some_on_first_page
    chart1 = @seatsio.charts.create
    chart2 = @seatsio.charts.create
    chart3 = @seatsio.charts.create

    charts = @seatsio.charts.list.first_page(2)
    charts_ids = charts.collect {|chart| chart.id}
    
    assert_equal([chart3.id, chart2.id], charts_ids)
    assert_equal(chart2.id, charts.next_page_starts_after)
    assert_nil(charts.previous_page_ends_before)
  end
end
