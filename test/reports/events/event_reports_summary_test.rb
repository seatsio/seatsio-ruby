require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/exception'

class EventReportsSummaryTest < SeatsioTestClient
  def test_summary_by_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.summary_by_status(event.key)

    assert_equal(1, report['booked']['count'])
    assert_equal(1, report['booked']['bySection']['NO_SECTION'])
    assert_equal(1, report['booked']['byCategoryKey']['9'])
    assert_equal(1, report['booked']['byCategoryLabel']['Cat1'])
    assert_equal(1, report['booked']['byChannel']['NO_CHANNEL'])

    assert_equal(231, report['free']['count'])
    assert_equal(231, report['free']['bySection']['NO_SECTION'])
    assert_equal(115, report['free']['byCategoryKey']['9'])
    assert_equal(116, report['free']['byCategoryKey']['10'])
    assert_equal(115, report['free']['byCategoryLabel']['Cat1'])
    assert_equal(116, report['free']['byCategoryLabel']['Cat2'])
    assert_equal(231, report['free']['byChannel']['NO_CHANNEL'])
  end

  def test_summary_by_object_type
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    report = @seatsio.event_reports.summary_by_object_type(event.key)

    assert_equal(32, report['seat']['count'])
    assert_equal(32, report['seat']['bySection']['NO_SECTION'])
    assert_equal(16, report['seat']['byCategoryKey']['9'])
    assert_equal(16, report['seat']['byCategoryKey']['10'])
    assert_equal(16, report['seat']['byCategoryLabel']['Cat1'])
    assert_equal(16, report['seat']['byCategoryLabel']['Cat2'])
    assert_equal(32, report['seat']['byChannel']['NO_CHANNEL'])
    assert_equal(32, report['seat']['byStatus']['free'])

    assert_equal(200, report['generalAdmission']['count'])
    assert_equal(200, report['generalAdmission']['bySection']['NO_SECTION'])
    assert_equal(100, report['generalAdmission']['byCategoryKey']['9'])
    assert_equal(100, report['generalAdmission']['byCategoryKey']['10'])
    assert_equal(100, report['generalAdmission']['byCategoryLabel']['Cat1'])
    assert_equal(100, report['generalAdmission']['byCategoryLabel']['Cat2'])
    assert_equal(200, report['generalAdmission']['byChannel']['NO_CHANNEL'])
    assert_equal(200, report['generalAdmission']['byStatus']['free'])
  end

  def test_summary_by_category_key
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.summary_by_category_key(event.key)

    assert_equal(116, report['9']['count'])
    assert_equal(116, report['9']['bySection']['NO_SECTION'])
    assert_equal(1, report['9']['byStatus']['booked'])
    assert_equal(115, report['9']['byStatus']['free'])
    assert_equal(116, report['9']['byChannel']['NO_CHANNEL'])

    assert_equal(116, report['10']['count'])
    assert_equal(116, report['10']['bySection']['NO_SECTION'])
    assert_equal(116, report['10']['byStatus']['free'])
    assert_equal(116, report['10']['byChannel']['NO_CHANNEL'])
  end

  def test_summary_by_category_label
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.summary_by_category_label(event.key)

    assert_equal(116, report['Cat1']['count'])
    assert_equal(116, report['Cat1']['bySection']['NO_SECTION'])
    assert_equal(1, report['Cat1']['byStatus']['booked'])
    assert_equal(115, report['Cat1']['byStatus']['free'])
    assert_equal(116, report['Cat1']['byChannel']['NO_CHANNEL'])

    assert_equal(116, report['Cat2']['count'])
    assert_equal(116, report['Cat2']['bySection']['NO_SECTION'])
    assert_equal(116, report['Cat2']['byStatus']['free'])
    assert_equal(116, report['Cat2']['byChannel']['NO_CHANNEL'])
  end

  def test_summary_by_section
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.summary_by_section(event.key)

    assert_equal(232, report['NO_SECTION']['count'])
    assert_equal(1, report['NO_SECTION']['byStatus']['booked'])
    assert_equal(231, report['NO_SECTION']['byStatus']['free'])
    assert_equal(116, report['NO_SECTION']['byCategoryKey']['9'])
    assert_equal(116, report['NO_SECTION']['byCategoryKey']['10'])
    assert_equal(116, report['NO_SECTION']['byCategoryLabel']['Cat1'])
    assert_equal(116, report['NO_SECTION']['byCategoryLabel']['Cat2'])
    assert_equal(232, report['NO_SECTION']['byChannel']['NO_CHANNEL'])
  end

  def test_summary_by_availability
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.summary_by_availability(event.key)

    assert_equal(231, report['available']['count'])
    assert_equal(231, report['available']['bySection']['NO_SECTION'])
    assert_equal(231, report['available']['byStatus']['free'])
    assert_equal(231, report['available']['byChannel']['NO_CHANNEL'])

    assert_equal(1, report['not_available']['count'])
    assert_equal(1, report['not_available']['bySection']['NO_SECTION'])
    assert_equal(1, report['not_available']['byStatus']['booked'])
    assert_equal(1, report['not_available']['byChannel']['NO_CHANNEL'])
  end

  def test_summary_by_availability_reason
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.book(event.key, ['A-1'])

    report = @seatsio.event_reports.summary_by_availability_reason(event.key)

    assert_equal(231, report['available']['count'])
    assert_equal(231, report['available']['bySection']['NO_SECTION'])
    assert_equal(231, report['available']['byStatus']['free'])
    assert_equal(231, report['available']['byChannel']['NO_CHANNEL'])

    assert_equal(1, report['booked']['count'])
    assert_equal(1, report['booked']['bySection']['NO_SECTION'])
    assert_equal(1, report['booked']['byStatus']['booked'])
    assert_equal(1, report['booked']['byChannel']['NO_CHANNEL'])
  end

  def test_summary_by_channel
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.channels.replace key: event.key, channels: {
      "channelKey1" => { "name" => "channel 1", "color" => "#FF0000", "index" => 1 },
    }
    @seatsio.events.channels.set_objects key: event.key, channelConfig: { "channelKey1" => ["A-1", "A-2"] }

    report = @seatsio.event_reports.summary_by_channel(event.key)

    assert_equal(230, report['NO_CHANNEL']['count'])
    assert_equal(230, report['NO_CHANNEL']['bySection']['NO_SECTION'])
    assert_equal(230, report['NO_CHANNEL']['byStatus']['free'])
    assert_equal(230, report['NO_CHANNEL']['byAvailability']['available'])

    assert_equal(2, report['channelKey1']['count'])
    assert_equal(2, report['channelKey1']['bySection']['NO_SECTION'])
    assert_equal(2, report['channelKey1']['byStatus']['free'])
    assert_equal(2, report['channelKey1']['byAvailability']['available'])
  end
end
