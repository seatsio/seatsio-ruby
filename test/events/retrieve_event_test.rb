require 'test_helper'
require 'util'

class RetrieveEventTest < SeatsioTestClient
  def test_retrieve_event
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key

    retrieved_event = @seatsio.events.retrieve(event.key)
    assert_operator(retrieved_event.id, :!=, 0)
    assert_operator(retrieved_event.key, :!=, nil)
    assert_equal(chart_key, retrieved_event.chart_key)
    assert_equal(false, retrieved_event.book_whole_tables)
    assert_equal(true, retrieved_event.supports_best_available)
    assert_nil(retrieved_event.for_sale_config)
    assert_nil(retrieved_event.updated_on)
    # TODO: assert_that(retrieved_event.created_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end
end
