require 'seatsio/exception'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio
  class ChartReportsClient
    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, base_url)
    end

    def by_label(chart_key)
      url = "reports/charts/#{chart_key}/byLabel"
      body = @http_client.get(url)
      Domain::ChartReport.new(body)
    end
  end
end
