require 'test_helper'
require 'util'

class EditForSaleConfigForEventsTest < SeatsioTestClient
  def test_for_sale
    chart_key = create_test_chart
    for_sale_config = Seatsio::ForSaleConfig.new(false, %w[A-1 A-2 A-3])
    event1 = @seatsio.events.create chart_key: chart_key, for_sale_config: for_sale_config
    event2 = @seatsio.events.create chart_key: chart_key, for_sale_config: for_sale_config

    events = {
      event1.key => { for_sale: [{ object: "A-1"}] },
      event2.key => { for_sale: [{ object: "A-2"}] }
    }

    @seatsio.events.edit_for_sale_config_for_events events

    retrieved_event1 = @seatsio.events.retrieve key: event1.key
    assert_equal(false, retrieved_event1.for_sale_config.for_sale)
    assert_equal(%w(A-2 A-3), retrieved_event1.for_sale_config.objects)

    retrieved_event2 = @seatsio.events.retrieve key: event2.key
    assert_equal(false, retrieved_event2.for_sale_config.for_sale)
    assert_equal(%w(A-1 A-3), retrieved_event2.for_sale_config.objects)
  end

  def test_returns_result
    chart_key = create_test_chart
    for_sale_config = Seatsio::ForSaleConfig.new(false, %w[A-1 A-2 A-3])
    event1 = @seatsio.events.create chart_key: chart_key, for_sale_config: for_sale_config
    event2 = @seatsio.events.create chart_key: chart_key, for_sale_config: for_sale_config

    events = {
      event1.key => { for_sale: [{ object: "A-1"}] },
      event2.key => { for_sale: [{ object: "A-2"}] }
    }

    result = @seatsio.events.edit_for_sale_config_for_events events

    assert_equal(false, result[event1.key].for_sale_config.for_sale)
    assert_equal(%w(A-2 A-3), result[event1.key].for_sale_config.objects)

    assert_equal(false, result[event2.key].for_sale_config.for_sale)
    assert_equal(%w(A-1 A-3), result[event2.key].for_sale_config.objects)
  end

  def test_not_for_sale
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key

    events = {
      event1.key => { not_for_sale: [{ object: "A-1"}] },
      event2.key => { not_for_sale: [{ object: "A-2"}] }
    }

    @seatsio.events.edit_for_sale_config_for_events events

    retrieved_event1 = @seatsio.events.retrieve key: event1.key
    assert_equal(false, retrieved_event1.for_sale_config.for_sale)
    assert_equal(%w(A-1), retrieved_event1.for_sale_config.objects)

    retrieved_event2 = @seatsio.events.retrieve key: event2.key
    assert_equal(false, retrieved_event2.for_sale_config.for_sale)
    assert_equal(%w(A-2), retrieved_event2.for_sale_config.objects)
  end
end
