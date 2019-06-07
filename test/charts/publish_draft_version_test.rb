require 'test_helper'
require 'util'

class PublishDraftVersionTest <SeatsioTestClient
  def test_publish_draft_version
    chart = @seatsio.charts.create name: 'oldname'
    @seatsio.events.create chart_key: chart.key
    @seatsio.charts.update key: chart.key, new_name: 'newname'

    @seatsio.charts.publish_draft_version(chart.key)

    retrieved_chart = @seatsio.charts.retrieve(chart.key)
    assert_equal('newname', retrieved_chart.name)
    assert_equal('PUBLISHED', retrieved_chart.status)
  end
end
