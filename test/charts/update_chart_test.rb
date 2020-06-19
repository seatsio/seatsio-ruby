require 'test_helper'
require 'util'

class UpdateChartTest < SeatsioTestClient
  def test_update_name
    categories = [
      {'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false},
      {'key' => 2, 'label' => 'Category 2', 'color' => '#bbbbbb', 'accessible' => true}
    ]
    chart = @seatsio.charts.create venue_type: 'BOOTHS', categories: categories

    @seatsio.charts.update key: chart.key, new_name: 'aChart'

    retrieved_chart = @seatsio.charts.retrieve(chart.key)
    assert_equal('aChart', retrieved_chart.name)

    drawing = @seatsio.charts.retrieve_published_version(retrieved_chart.key)
    assert_equal('BOOTHS', drawing['venueType'])
    assert_equal(categories, drawing['categories']['list'])
  end
end
