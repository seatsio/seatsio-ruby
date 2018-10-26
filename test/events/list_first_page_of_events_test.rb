require 'test_helper'
require 'util'

class ListFirstPageOfEventsTest < Minitest::Test

  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_all_on_first_page
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create(chart.key)
    event2 = @seatsio.events.create(chart.key)
    event3 = @seatsio.events.create(chart.key)

    events = @seatsio.events.list.first_page

    assert_equal([event3.id, event2.id, event1.id], events.collect {|event| event.id})
    assert_nil(events.next_page_starts_after)
    assert_nil(events.previous_page_ends_before)
  end

  def test_some_on_first_page
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create(chart.key)
    event2 = @seatsio.events.create(chart.key)
    event3 = @seatsio.events.create(chart.key)

    events = @seatsio.events.list.first_page(2)

    assert_equal([event3.id, event2.id], events.collect {|event| event.id})
    assert_equal(event2.id, events.next_page_starts_after)
    assert_nil(events.previous_page_ends_before)
  end

end
