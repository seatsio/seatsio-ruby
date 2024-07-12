require 'seatsio/exception'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio
  class ChartReportsClient

    def initialize(http_client)
      @http_client = http_client
    end

    def by_label(chart_key, book_whole_tables = nil, version = nil)
      fetch_chart_report('byLabel', chart_key, book_whole_tables, version)
    end

    def by_object_type(chart_key, book_whole_tables = nil, version = nil)
      fetch_chart_report('byObjectType', chart_key, book_whole_tables, version)
    end

    def summary_by_object_type(chart_key, book_whole_tables = nil, version = nil)
      fetch_summary_report('byObjectType', chart_key, book_whole_tables, version)
    end

    def by_category_key(chart_key, book_whole_tables = nil, version = nil)
      fetch_chart_report('byCategoryKey', chart_key, book_whole_tables, version)
    end

    def summary_by_category_key(chart_key, book_whole_tables = nil, version = nil)
      fetch_summary_report('byCategoryKey', chart_key, book_whole_tables, version)
    end

    def by_category_label(chart_key, book_whole_tables = nil, version = nil)
      fetch_chart_report('byCategoryLabel', chart_key, book_whole_tables, version)
    end

    def summary_by_category_label(chart_key, book_whole_tables = nil, version = nil)
      fetch_summary_report('byCategoryLabel', chart_key, book_whole_tables, version)
    end

    def by_section(chart_key, book_whole_tables = nil, version = nil)
      fetch_chart_report('bySection', chart_key, book_whole_tables, version)
    end

    def summary_by_section(event_key, book_whole_tables = nil, version = nil)
      fetch_summary_report('bySection', event_key, book_whole_tables, version)
    end

    def by_zone(chart_key, book_whole_tables = nil, version = nil)
      fetch_chart_report('byZone', chart_key, book_whole_tables, version)
    end

    def summary_by_zone(event_key, book_whole_tables = nil, version = nil)
      fetch_summary_report('byZone', event_key, book_whole_tables, version)
    end

    private

    def fetch_chart_report(report_type, chart_key, book_whole_tables, version)
      params = book_whole_tables.nil? ? {} : { bookWholeTables: book_whole_tables }
      unless version.nil?
        params[:version] = version
      end
      url = "reports/charts/#{chart_key}/#{report_type}"
      body = @http_client.get(url, params)
      ChartReport.new(body)
    end

    def fetch_summary_report(report_type, chart_key, book_whole_tables, version)
      params = book_whole_tables.nil? ? {} : { bookWholeTables: book_whole_tables }
      unless version.nil?
        params[:version] = version
      end
      url = "reports/charts/#{chart_key}/#{report_type}/summary"
      @http_client.get(url, params)
    end
  end

end
