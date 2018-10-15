require "seatsio/charts"
require "seatsio/subaccounts"

module Seatsio
  class Client

    attr_accessor :charts, :subaccounts

    def initialize(secret_key, base_url)
      @charts = ::Seatsio::ChartsClient.new(secret_key, base_url)
      @subaccounts = ::Seatsio::SubaccountsClient.new(secret_key, base_url)
    end

    def base_url
      @base_url
    end

  end
end