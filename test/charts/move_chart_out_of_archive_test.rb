require 'test_helper'
require 'util'

class MoveChartOutOfArchiveTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_move_chart_out_of_archive
    chart = @seatsio.charts.create
    @seatsio.charts.move_to_archive(chart.key)

    @seatsio.charts.move_out_of_archive(chart.key)

    retrieved_chart = @seatsio.charts.retrieve(chart.key)

    assert_equal(false, retrieved_chart.archived)
  end
end
