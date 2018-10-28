require 'test_helper'
require 'util'

class MoveChartToArchiveTest < SeatsioTestClient
  def test_move_to_archive
    chart = @seatsio.charts.create
    @seatsio.charts.move_to_archive(chart.key)

    retrieved_chart = @seatsio.charts.retrieve(chart.key)

    assert_equal(true, retrieved_chart.archived)
  end
end
