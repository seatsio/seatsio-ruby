require 'test_helper'
require 'util'

class RetrieveDraftVersionTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_retrieve_draft_version
    chart = @seatsio.charts.create
    @seatsio.events.create(chart.key)
    @seatsio.charts.update(chart.key, 'newname')

    draft_drawing = @seatsio.charts.retrieve_draft_version(chart.key)

    assert_equal('newname', draft_drawing.name)
  end
end
