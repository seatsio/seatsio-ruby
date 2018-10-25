require 'seatsio/exception'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio
  class EventReportsClient

    attr_reader :archive

    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, base_url)
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

    private

    def fetch_summary_report(report_type, event_key)
      url = "reports/events/#{event_key}/#{report_type}/summary"
      @http_client.get(url)
    end

    def fetch_report(report_type, event_key, report_filter = nil)
      if report_filter
        url = "reports/events/#{event_key}/#{report_type}/#{report_filter}"
        body = @http_client.get(url)
        result = []
        body[report_filter].each do |report_item|
          result.append(EventReportItem(report_item))
          return result
        end
      else
        url = "reports/events/#{event_key}/#{report_type}"
        body = @http_client.get(url)
        Domain::EventReport.new(body)
      end
    end
  end
end
