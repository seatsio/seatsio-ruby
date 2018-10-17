require 'test_helper'
require 'util'

class ListAllChartsTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_all
    chart1 = @seatsio.client.charts.create
    chart2 = @seatsio.client.charts.create
    chart3 = @seatsio.client.charts.create

    charts = @seatsio.client.charts.list

    keys = charts.collect {|chart| chart['key']}

    assert_includes(keys, chart1.key)
    assert_includes(keys, chart2.key)
    assert_includes(keys, chart3.key)
  end

  def test_filter

  end

  def test_tag

  end

  def test_tag_and_filter

  end

  def test_expand

  end
end