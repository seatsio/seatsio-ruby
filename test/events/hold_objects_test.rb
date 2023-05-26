require 'test_helper'
require 'util'

class HoldObjectsTest < SeatsioTestClient
  def test_with_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    res = @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token)

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::HELD, object_info1.status)
    assert_equal(hold_token.hold_token, object_info1.hold_token)

    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-2'
    assert_equal(Seatsio::EventObjectInfo::HELD, object_info2.status)
    assert_equal(hold_token.hold_token, object_info2.hold_token)

    assert_equal(res.objects.keys.sort, ['A-1', 'A-2'])
  end

  def test_with_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token, order_id: 'order1')

    object_info1 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal('order1', object_info1.order_id)

    object_info2 = @seatsio.events.retrieve_object_info key: event.key, label: 'A-2'
    assert_equal('order1', object_info2.order_id)
  end

  def test_keep_extra_data_true
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {'name' => 'John Doe'}
    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data
    hold_token = @seatsio.hold_tokens.create

    @seatsio.events.hold(event.key, 'A-1', hold_token.hold_token, keep_extra_data: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(extra_data, object_info.extra_data)
  end

  def test_channel_keys
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.channels.replace key: event.key, channels: [
      { "key" => "channelKey1", "name" => "channel 1", "color" => "#FF0000", "index" => 1, "objects" => %w[A-1 A-2] }
    ]

    @seatsio.events.hold(event.key, 'A-1', hold_token.hold_token, channel_keys: ["channelKey1"])

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::HELD, object_info.status)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.channels.replace key: event.key, channels: [
      { "key" => "channelKey1", "name" => "channel 1", "color" => "#FF0000", "index" => 1, "objects" => %w[A-1 A-2] }
    ]

    @seatsio.events.hold(event.key, 'A-1', hold_token.hold_token, ignore_channels: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::HELD, object_info.status)
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
    event = @seatsio.events.create chart_key: chart_key, social_distancing_ruleset_key: "ruleset"
    hold_token = @seatsio.hold_tokens.create

    @seatsio.events.hold(event.key, 'A-1', hold_token.hold_token, ignore_social_distancing: true)

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::HELD, object_info.status)
  end
end
