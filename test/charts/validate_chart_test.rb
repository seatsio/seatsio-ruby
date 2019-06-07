require 'test_helper'
require 'util'

class ValidateChartTest < SeatsioTestClient

  def test_validate_published_chart
    chart_key = create_test_chart_with_errors()
    validation = @seatsio.charts.validate_published_version(chart_key)
    assert_equal(validation.errors, %w(VALIDATE_DUPLICATE_LABELS VALIDATE_UNLABELED_OBJECTS VALIDATE_OBJECTS_WITHOUT_CATEGORIES))
  end

  def test_validate_draft_chart
    assert_raises Seatsio::Exception::SeatsioException do
      chart_key = create_test_chart_with_errors()
      @seatsio.events.create chart_key: chart_key
      @seatsio.charts.update key: chart_key, new_name: "New name"
      validation = @seatsio.charts.validate_draft_version(chart_key)
    end
  end

end
