require "seatsio/charts"

module Seatsio
  class Client
    def initialize(secret_key, base_url)
      @charts_client = ::Seatsio::ChartsClient.new(secret_key, base_url)
    end

    def base_url
      @base_url
    end

    def charts
      @charts_client
    end
  end
end