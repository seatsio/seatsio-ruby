require "seatsio/charts"
require "seatsio/accounts"
require "seatsio/subaccounts"
require "seatsio/events"
require "seatsio/hold_tokens"

module Seatsio
  class Client

    attr_reader :charts, :accounts, :subaccounts, :events, :hold_tokens

    def initialize(secret_key, base_url)
      @charts = ::Seatsio::ChartsClient.new(secret_key, base_url)
      @accounts = ::Seatsio::AccountsClient.new(secret_key, base_url)
      @subaccounts = ::Seatsio::SubaccountsClient.new(secret_key, base_url)
      @events = ::Seatsio::EventsClient.new(secret_key, base_url)
      @hold_tokens = ::Seatsio::HoldTokensClient.new(secret_key, base_url)
    end
  end
end
