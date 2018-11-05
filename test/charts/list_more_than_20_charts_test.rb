require 'test_helper'
require 'util'

class ListMoreThan20ChartsTest < SeatsioTestClient
  def setup
    super
    charts_list = []
    30.times.each do
      charts_list << @seatsio.charts.create
    end
  end

  def test_list_more_than_20_charts
    first_page = @seatsio.charts.list.first_page.to_a
    second_page = @seatsio.charts.list.page_after(first_page.last.id).to_a

    assert_equal(20, first_page.length)
    assert_equal(10, second_page.length)
  end

  def test_list_more_than_20_charts_with_smaller_page
    first_page = @seatsio.charts.list.first_page(10).to_a
    second_page = @seatsio.charts.list.page_after(first_page.last.id, 10).to_a

    assert_equal(10, first_page.length)
    assert_equal(10, second_page.length)
  end
end
