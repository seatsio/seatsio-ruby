require 'test_helper'
require 'util'

class MoveChartToArchiveTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_move_to_archive
    chart = @seatsio.client.charts.create
    @seatsio.client.charts.move_to_archive(chart.key)

    retrieved_chart = @seatsio.client.charts.retrieve(chart.key)

    assert_equal(true, retrieved_chart.archived)
  end
end