require "seatsio/charts"
require "seatsio/accounts"
require "seatsio/subaccounts"
require "seatsio/events"

module Seatsio
  class Client

    attr_accessor :charts, :accounts, :subaccounts, :events

    def initialize(secret_key, base_url)
      @charts = ::Seatsio::ChartsClient.new(secret_key, base_url)
      @accounts = ::Seatsio::AccountsClient.new(secret_key, base_url)
      @subaccounts = ::Seatsio::SubaccountsClient.new(secret_key, base_url)
      @events = ::Seatsio::EventsClient.new(secret_key, base_url)
    end
  end
end
