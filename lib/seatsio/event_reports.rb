require 'seatsio/exception'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio
  # Client for fetching event reports
  class EventReportsClient
    def initialize(secret_key, workspace_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, workspace_key, base_url)
    end

    def summary_by_status(event_key)
      fetch_summary_report('byStatus', event_key)
    end

    def summary_by_category_key(event_key)
      fetch_summary_report('byCategoryKey', event_key)
    end

    def summary_by_category_label(event_key)
      fetch_summary_report('byCategoryLabel', event_key)
    end

    def summary_by_section(event_key)
      fetch_summary_report('bySection', event_key)
    end

    def summary_by_selectability(event_key)
      fetch_summary_report('bySelectability', event_key)
    end

    def summary_by_channel(event_key)
      fetch_summary_report('byChannel', event_key)
    end

    def by_label(event_key, label = nil)
      fetch_report('byLabel', event_key, label)
    end

    def by_status(event_key, status = nil)
      fetch_report('byStatus', event_key, status)
    end

    def by_category_label(event_key, category_label = nil)
      fetch_report('byCategoryLabel', event_key, category_label)
    end

    def by_category_key(event_key, category_key = nil)
      fetch_report('byCategoryKey', event_key, category_key)
    end

    def by_order_id(event_key, order_id = nil)
      fetch_report('byOrderId', event_key, order_id)
    end

    def by_section(event_key, section = nil)
      fetch_report('bySection', event_key, section)
    end

    def by_selectability(event_key, selectability = nil)
      fetch_report('bySelectability', event_key, selectability)
    end

    def by_channel(event_key, channelKey = nil)
      fetch_report('byChannel', event_key, channelKey)
    end

    private

    def fetch_summary_report(report_type, event_key)
      url = "reports/events/#{event_key}/#{report_type}/summary"
      @http_client.get(url)
    end

    def fetch_report(report_type, event_key, report_filter = nil)
      if report_filter
        url = "reports/events/#{event_key}/#{report_type}/#{report_filter}"
        body = @http_client.get(url)
        Domain::EventReport.new(body[report_filter])
      else
        url = "reports/events/#{event_key}/#{report_type}"
        body = @http_client.get(url)
        Domain::EventReport.new(body)
      end
    end
  end
end
