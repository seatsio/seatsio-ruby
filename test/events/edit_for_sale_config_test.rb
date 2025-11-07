require 'test_helper'
require 'util'

class EditForSaleConfigTest < SeatsioTestClient
  def test_for_sale
    chart_key = create_test_chart
    for_sale_config = Seatsio::ForSaleConfig.new(false, %w[A-1 A-2 A-3])
    event = @seatsio.events.create chart_key: chart_key, for_sale_config: for_sale_config

    @seatsio.events.edit_for_sale_config key: event.key, for_sale: [{ object: "A-1"}, { object: "A-2"}]

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(false, retrieved_event.for_sale_config.for_sale)
    assert_equal(%w(A-3), retrieved_event.for_sale_config.objects)
  end

  def test_not_for_sale
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.edit_for_sale_config key: event.key, not_for_sale: [{ object: "A-1"}, { object: "A-2"}]

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(false, retrieved_event.for_sale_config.for_sale)
    assert_equal(%w(A-1 A-2), retrieved_event.for_sale_config.objects)
  end

  def test_area_places
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.edit_for_sale_config key: event.key, not_for_sale: [{ object: "GA1", quantity: 5}]

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(false, retrieved_event.for_sale_config.for_sale)
    assert_equal({ 'GA1' => 5 }, retrieved_event.for_sale_config.area_places)
  end
end
