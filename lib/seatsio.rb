require 'seatsio/version'
require "seatsio/charts"
require "seatsio/accounts"
require "seatsio/subaccounts"
require "seatsio/events"
require "seatsio/hold_tokens"
require "seatsio/reports"

module Seatsio
  # Main Seatsio Class
  class Client
    attr_reader :charts, :accounts, :subaccounts, :events, :hold_tokens, :reports

    def initialize(secret_key, base_url = 'https://api.seatsio.net')
      @charts = ChartsClient.new(secret_key, base_url)
      @accounts = AccountsClient.new(secret_key, base_url)
      @subaccounts = SubaccountsClient.new(secret_key, base_url)
      @events = EventsClient.new(secret_key, base_url)
      @hold_tokens = HoldTokensClient.new(secret_key, base_url)
      @reports = ReportsClient.new(secret_key, base_url)
    end
  end
end
