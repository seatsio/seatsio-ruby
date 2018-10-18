require 'test_helper'
require 'util'

class ListPageOfChartsAfterTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_with_previous_page
    chart1 = @seatsio.client.charts.create
    chart2 = @seatsio.client.charts.create
    chart3 = @seatsio.client.charts.create

    charts = @seatsio.client.charts.list.page_after(chart3.id)

    charts_ids = charts.collect {|chart| chart.id}

    assert_equal([chart2.id, chart1.id], charts_ids)
    assert_nil(charts.next_page_starts_after)
    assert_equal(chart2.id, charts.previous_page_ends_before)
  end

  def test_with_next_and_previous_pages
    chart1 = @seatsio.client.charts.create
    chart2 = @seatsio.client.charts.create
    chart3 = @seatsio.client.charts.create

    charts = @seatsio.client.charts.list.page_after(chart3.id, 1)

    charts_ids = charts.collect {|chart| chart.id}

    assert_equal([chart2.id], charts_ids)
    assert_equal(charts.next_page_starts_after, chart2.id)
    assert_equal(charts.previous_page_ends_before, chart2.id)
    #assert_that(charts.items).extracting("id").contains_exactly(chart2.id)
    #assert_that(charts.next_page_starts_after).is_equal_to(chart2.id)
    #assert_that(charts.previous_page_ends_before).is_equal_to(chart2.id)
  end
end