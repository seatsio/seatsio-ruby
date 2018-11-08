require 'test_helper'
require 'util'

class DiscardDraftVersionTest < SeatsioTestClient
  def test_discard_draft
    chart = @seatsio.charts.create name: 'oldname'
    @seatsio.events.create key: chart.key
    @seatsio.charts.update key: chart.key, new_name: 'newname'

    @seatsio.charts.discard_draft_version(chart.key)

    retrieved_chart = @seatsio.charts.retrieve(chart.key)
    assert_equal('oldname', retrieved_chart.name)
    assert_equal('PUBLISHED', retrieved_chart.status)
  end
end
