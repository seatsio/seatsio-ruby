require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChangeObjectStatusInBatchTest < SeatsioTestClient
  def test_change_object_status_in_batch
    chart_key1 = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key1
    chart_key2 = create_test_chart
    event2 = @seatsio.events.create chart_key: chart_key2

    res = @seatsio.events.change_object_status_in_batch([{ :event => event1.key, :objects => ['A-1'], :status => 'foo' }, { :event => event2.key, :objects => ['A-2'], :status => 'fa' }])

    assert_equal('foo', res[0].objects['A-1'].status)
    assert_equal('foo', @seatsio.events.retrieve_object_info(key: event1.key, label: 'A-1').status)

    assert_equal('fa', res[1].objects['A-2'].status)
    assert_equal('fa', @seatsio.events.retrieve_object_info(key: event2.key, label: 'A-2').status)
  end

  def test_channel_keys
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, channels: [
      Seatsio::Channel.new("channelKey1", "channel 1", "#FF0000", 1, %w[A-1])
    ]

    res = @seatsio.events.change_object_status_in_batch([{ :event => event.key, :objects => ['A-1'], :status => 'foo', :channelKeys => ['channelKey1'] }])

    assert_equal('foo', res[0].objects['A-1'].status)
  end

  def test_ignore_channels
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, channels: [
      Seatsio::Channel.new("channelKey1", "channel 1", "#FF0000", 1, %w[A-1])
    ]

    res = @seatsio.events.change_object_status_in_batch([{ :event => event.key, :objects => ['A-1'], :status => 'foo', :ignoreChannels => true }])

    assert_equal('foo', res[0].objects['A-1'].status)
  end

  def test_allowed_previous_statuses
    begin
      chart_key = create_test_chart
      event = @seatsio.events.create chart_key: chart_key

      @seatsio.events.change_object_status_in_batch([{
                                                       :event => event.key,
                                                       :objects => ['A-1'],
                                                       :status => 'foo',
                                                       :ignoreChannels => true,
                                                       :allowedPreviousStatuses => ['someOtherStatus']
                                                     }])
      raise "Should have failed: expected SeatsioException"
    rescue Seatsio::Exception::SeatsioException => e
      assert_equal(400, e.message.code)
      assert_match /ILLEGAL_STATUS_CHANGE/, e.message.body
      assert_match /free is not in the list of allowed previous statuses/, e.message.body
    end
  end

  def test_rejected_previous_statuses
    begin
      chart_key = create_test_chart
      event = @seatsio.events.create chart_key: chart_key

      @seatsio.events.change_object_status_in_batch([{
                                                       :event => event.key,
                                                       :objects => ['A-1'],
                                                       :status => 'foo',
                                                       :ignoreChannels => true,
                                                       :rejectedPreviousStatuses => ['free']
                                                     }])
      raise "Should have failed: expected SeatsioException"
    rescue Seatsio::Exception::SeatsioException => e
      assert_equal(400, e.message.code)
      assert_match /ILLEGAL_STATUS_CHANGE/, e.message.body
      assert_match /free is in the list of rejected previous statuses/, e.message.body
    end
  end

  def release_in_batch
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.book(event.key, ['A-1'])

    res = @seatsio.events.change_object_status_in_batch([{ :type => 'RELEASE', :event => event.key, :objects => ['A-1'] }])

    assert_equal(Seatsio::EventObjectInfo::FREE, res[0].objects['A-1'].status)
    assert_equal(Seatsio::EventObjectInfo::FREE, @seatsio.events.retrieve_object_info(key: event.key, label: 'A-1').status)
  end
end
