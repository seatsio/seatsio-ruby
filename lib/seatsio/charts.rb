require "seatsio/exception"
require "base64"
require "seatsio/httpClient"

module Seatsio
  class ChartsClient
    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, base_url)
    end

    def retrieve(chart_key)
      @http_client.get("/charts/" + chart_key)
    end
  end
end