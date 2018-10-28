require 'test_helper'
require 'util'

class ListChartsInArchiveTest < SeatsioTestClient
  def test_charts_in_archive
    chart1 = @seatsio.charts.create
    chart2 = @seatsio.charts.create
    chart3 = @seatsio.charts.create

    @seatsio.charts.move_to_archive(chart1.key)
    @seatsio.charts.move_to_archive(chart3.key)

    charts_in_archive = @seatsio.charts.archive
    
    keys = charts_in_archive.collect {|chart| chart.key}
    
    assert_equal([chart3.key, chart1.key], keys)
  end
end
