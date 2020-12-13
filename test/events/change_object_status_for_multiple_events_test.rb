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
    assert_equal(Seatsio::ObjectStatus::BOOKED, fetch_status(event1.key, 'A-1'))
    assert_equal(Seatsio::ObjectStatus::BOOKED, fetch_status(event2.key, 'A-1'))
    assert_equal(Seatsio::ObjectStatus::BOOKED, fetch_status(event1.key, 'A-2'))
    assert_equal(Seatsio::ObjectStatus::BOOKED, fetch_status(event2.key, 'A-2'))
  end

  def test_hold
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    @seatsio.events.hold([event1.key, event2.key], %w(A-1 A-2), hold_token.hold_token)

    assert_equal(Seatsio::ObjectStatus::HELD, fetch_status(event1.key, 'A-1'))
    assert_equal(Seatsio::ObjectStatus::HELD, fetch_status(event2.key, 'A-1'))
    assert_equal(Seatsio::ObjectStatus::HELD, fetch_status(event1.key, 'A-2'))
    assert_equal(Seatsio::ObjectStatus::HELD, fetch_status(event2.key, 'A-2'))
  end

  def test_release
    chart_key = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key
    event2 = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book([event1.key, event2.key], %w(A-1 A-2))

    @seatsio.events.release([event1.key, event2.key], %w(A-1 A-2))

    assert_equal(Seatsio::ObjectStatus::FREE, fetch_status(event1.key, 'A-1'))
    assert_equal(Seatsio::ObjectStatus::FREE, fetch_status(event2.key, 'A-1'))
    assert_equal(Seatsio::ObjectStatus::FREE, fetch_status(event1.key, 'A-2'))
    assert_equal(Seatsio::ObjectStatus::FREE, fetch_status(event2.key, 'A-2'))
  end

  def fetch_status(event, o)
    @seatsio.events.retrieve_object_status(key: event, object_key: o).status
  end

  def test_ignore_social_distancing
    chart_key = create_test_chart
    rulesets = {
        "ruleset" => {
            "name" => "ruleset",
            "fixedGroupLayout" => true,
            "disabledSeats" => ["A-1"]
        }
    }
    @seatsio.charts.save_social_distancing_rulesets(chart_key, rulesets)
    event1 = @seatsio.events.create chart_key: chart_key, social_distancing_ruleset_key: "ruleset"
    event2 = @seatsio.events.create chart_key: chart_key, social_distancing_ruleset_key: "ruleset"

    @seatsio.events.book([event1.key, event2.key], %w(A-1), ignore_social_distancing: true)

    assert_equal(Seatsio::ObjectStatus::BOOKED, fetch_status(event1.key, 'A-1'))
    assert_equal(Seatsio::ObjectStatus::BOOKED, fetch_status(event2.key, 'A-1'))
  end
end
