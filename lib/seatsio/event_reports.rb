require 'seatsio/exception'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio
  # Client for fetching event reports
  class EventReportsClient
    def initialize(http_client)
      @http_client = http_client
    end

    def by_status(event_key, status = nil)
      fetch_report('byStatus', event_key, status)
    end

    def summary_by_status(event_key)
      fetch_summary_report('byStatus', event_key)
    end

    def deep_summary_by_status(event_key)
      fetch_deep_summary_report('byStatus', event_key)
    end

    def by_object_type(event_key, object_type = nil)
      fetch_report('byObjectType', event_key, object_type)
    end

    def summary_by_object_type(event_key)
      fetch_summary_report('byObjectType', event_key)
    end

    def deep_summary_by_object_type(event_key)
      fetch_deep_summary_report('byObjectType', event_key)
    end

    def by_category_key(event_key, category_key = nil)
      fetch_report('byCategoryKey', event_key, category_key)
    end

    def summary_by_category_key(event_key)
      fetch_summary_report('byCategoryKey', event_key)
    end

    def deep_summary_by_category_key(event_key)
      fetch_deep_summary_report('byCategoryKey', event_key)
    end

    def by_category_label(event_key, category_label = nil)
      fetch_report('byCategoryLabel', event_key, category_label)
    end

    def summary_by_category_label(event_key)
      fetch_summary_report('byCategoryLabel', event_key)
    end

    def deep_summary_by_category_label(event_key)
      fetch_deep_summary_report('byCategoryLabel', event_key)
    end

    def by_section(event_key, section = nil)
      fetch_report('bySection', event_key, section)
    end

    def summary_by_section(event_key)
      fetch_summary_report('bySection', event_key)
    end

    def deep_summary_by_section(event_key)
      fetch_deep_summary_report('bySection', event_key)
    end

    def by_zone(event_key, zone = nil)
      fetch_report('byZone', event_key, zone)
    end

    def summary_by_zone(event_key)
      fetch_summary_report('byZone', event_key)
    end

    def deep_summary_by_zone(event_key)
      fetch_deep_summary_report('byZone', event_key)
    end

    def by_availability(event_key, availability = nil)
      fetch_report('byAvailability', event_key, availability)
    end

    def summary_by_availability(event_key)
      fetch_summary_report('byAvailability', event_key)
    end

    def deep_summary_by_availability(event_key)
      fetch_deep_summary_report('byAvailability', event_key)
    end

    def by_availability_reason(event_key, availability_reason = nil)
      fetch_report('byAvailabilityReason', event_key, availability_reason)
    end

    def summary_by_availability_reason(event_key)
      fetch_summary_report('byAvailabilityReason', event_key)
    end

    def deep_summary_by_availability_reason(event_key)
      fetch_deep_summary_report('byAvailabilityReason', event_key)
    end

    def by_channel(event_key, channelKey = nil)
      fetch_report('byChannel', event_key, channelKey)
    end

    def summary_by_channel(event_key)
      fetch_summary_report('byChannel', event_key)
    end

    def deep_summary_by_channel(event_key)
      fetch_deep_summary_report('byChannel', event_key)
    end

    def by_label(event_key, label = nil)
      fetch_report('byLabel', event_key, label)
    end

    def by_order_id(event_key, order_id = nil)
      fetch_report('byOrderId', event_key, order_id)
    end

    private

    def fetch_summary_report(report_type, event_key)
      url = "reports/events/#{event_key}/#{report_type}/summary"
      @http_client.get(url)
    end

    def fetch_deep_summary_report(report_type, event_key)
      url = "reports/events/#{event_key}/#{report_type}/summary/deep"
      @http_client.get(url)
    end

    def fetch_report(report_type, event_key, report_filter = nil)
      if report_filter
        url = "reports/events/#{event_key}/#{report_type}/#{report_filter}"
        body = @http_client.get(url)
        EventReport.new(body[report_filter])
      else
        url = "reports/events/#{event_key}/#{report_type}"
        body = @http_client.get(url)
        EventReport.new(body)
      end
    end
  end
end
