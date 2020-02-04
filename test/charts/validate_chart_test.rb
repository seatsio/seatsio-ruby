require 'test_helper'
require 'util'

class ValidateChartTest < SeatsioTestClient

  def test_validate_published_chart
    chart_key = create_test_chart_with_errors()
    validation = @seatsio.charts.validate_published_version(chart_key)
    assert_empty(validation.errors)
  end

  def test_validate_draft_chart
    chart_key = create_test_chart_with_errors()
    @seatsio.events.create chart_key: chart_key
    @seatsio.charts.update key: chart_key, new_name: "New name"
    validation = @seatsio.charts.validate_draft_version(chart_key)
    assert_empty(validation.errors)
  end

end
