require 'seatsio/exception'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio
  class ChartReportsClient
    def initialize(secret_key, workspace_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, workspace_key, base_url)
    end

    def by_label(chart_key, book_whole_tables = nil)
      get_chart_report('byLabel', chart_key, book_whole_tables)
    end

    def by_category_key(chart_key, book_whole_tables = nil)
      get_chart_report('byCategoryKey', chart_key, book_whole_tables)
    end

    def by_category_label(chart_key, book_whole_tables = nil)
      get_chart_report('byCategoryLabel', chart_key, book_whole_tables)
    end

    private

    def get_chart_report(report_type, chart_key, book_whole_tables)
      params = book_whole_tables.nil? ? {} : { bookWholeTables: book_whole_tables }
      url = "reports/charts/#{chart_key}/#{report_type}"
      body = @http_client.get(url, params)
      ChartReport.new(body)
    end
  end
end
