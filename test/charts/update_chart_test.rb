require 'test_helper'
require 'util'

class UpdateChartTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_update_name
    categories = [{'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa'}]
    chart = @seatsio.client.charts.create(nil, 'BOOTHS', categories)

    @seatsio.client.charts.update(chart.key, 'aChart')

    retrieved_chart = @seatsio.client.charts.retrieve(chart.key)
    assert_equal('aChart', retrieved_chart.name)

    drawing = @seatsio.client.charts.retrieve_published_version(retrieved_chart.key)
    assert_equal('BOOTHS', drawing.venue_type)
    assert_equal(categories, drawing.categories.list)
  end
end
