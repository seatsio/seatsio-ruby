require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChangeObjectStatusForMultipleEventsTest < SeatsioTestClient
  def test_custom_status
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key

    @seatsio.events.change_object_status([event1.key, event2.key], %w(A-1 A-2), 'stat')

    assert_equal('stat', fetch_status(event1.key, 'A-1'))
    assert_equal('stat', fetch_status(event2.key, 'A-1'))
    assert_equal('stat', fetch_status(event1.key, 'A-2'))
    assert_equal('stat', fetch_status(event2.key, 'A-2'))
  end

  def test_book
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book([event1.key, event2.key], %w(A-1 A-2))
    assert_equal(Seatsio::EventObjectInfo::BOOKED, fetch_status(event1.key, 'A-1'))
    assert_equal(Seatsio::EventObjectInfo::BOOKED, fetch_status(event2.key, 'A-1'))
    assert_equal(Seatsio::EventObjectInfo::BOOKED, fetch_status(event1.key, 'A-2'))
    assert_equal(Seatsio::EventObjectInfo::BOOKED, fetch_status(event2.key, 'A-2'))
  end

  def test_put_up_for_resale
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key

    @seatsio.events.put_up_for_resale([event1.key, event2.key], %w(A-1 A-2))
    assert_equal(Seatsio::EventObjectInfo::RESALE, fetch_status(event1.key, 'A-1'))
    assert_equal(Seatsio::EventObjectInfo::RESALE, fetch_status(event2.key, 'A-1'))
    assert_equal(Seatsio::EventObjectInfo::RESALE, fetch_status(event1.key, 'A-2'))
    assert_equal(Seatsio::EventObjectInfo::RESALE, fetch_status(event2.key, 'A-2'))
  end

  def test_hold
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    @seatsio.events.hold([event1.key, event2.key], %w(A-1 A-2), hold_token.hold_token)

    assert_equal(Seatsio::EventObjectInfo::HELD, fetch_status(event1.key, 'A-1'))
    assert_equal(Seatsio::EventObjectInfo::HELD, fetch_status(event2.key, 'A-1'))
    assert_equal(Seatsio::EventObjectInfo::HELD, fetch_status(event1.key, 'A-2'))
    assert_equal(Seatsio::EventObjectInfo::HELD, fetch_status(event2.key, 'A-2'))
  end

  def test_release
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book([event1.key, event2.key], %w(A-1 A-2))

    @seatsio.events.release([event1.key, event2.key], %w(A-1 A-2))

    assert_equal(Seatsio::EventObjectInfo::FREE, fetch_status(event1.key, 'A-1'))
    assert_equal(Seatsio::EventObjectInfo::FREE, fetch_status(event2.key, 'A-1'))
    assert_equal(Seatsio::EventObjectInfo::FREE, fetch_status(event1.key, 'A-2'))
    assert_equal(Seatsio::EventObjectInfo::FREE, fetch_status(event2.key, 'A-2'))
  end

  def fetch_status(event, o)
    @seatsio.events.retrieve_object_info(key: event, label: o).status
  end
end
