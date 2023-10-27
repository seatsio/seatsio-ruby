require 'test_helper'
require 'util'
require 'seatsio/domain'

class OverrideSeasonObjectStatusTest < SeatsioTestClient
  def test_override_season_object_status
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key, event_keys: %w[event1]
    @seatsio.events.book(season.key, ["A-1", "A-2"])

    @seatsio.events.override_season_object_status(key: "event1", objects: %w(A-1 A-2))

    a1_status = @seatsio.events.retrieve_object_info(key: "event1", label: 'A-1').status
    a2_status = @seatsio.events.retrieve_object_info(key: "event1", label: 'A-2').status

    assert_equal(Seatsio::EventObjectInfo::FREE, a1_status)
    assert_equal(Seatsio::EventObjectInfo::FREE, a2_status)
  end
end
