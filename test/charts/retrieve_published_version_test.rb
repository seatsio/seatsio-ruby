require 'test_helper'
require 'util'

class RetrievePublishedVersionTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_retrieve_published_version
    chart = @seatsio.client.charts.create('chartName')
    published_drawing = @seatsio.client.charts.retrieve_published_version(chart.key)
    assert_equal('chartName', published_drawing.name)
  end
end
