require 'test_helper'
require 'util'

class DiscardDraftVersionTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_discard_draft
    chart = @seatsio.charts.create("oldname")
    @seatsio.events.create(chart.key)
    @seatsio.charts.update(chart.key, "newname")

    @seatsio.charts.discard_draft_version(chart.key)

    retrieved_chart = @seatsio.charts.retrieve(chart.key)
    assert_equal('oldname', retrieved_chart.name)
    assert_equal('PUBLISHED', retrieved_chart.status)
  end
end
