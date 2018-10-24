require 'seatsio/version'
require "seatsio/charts"
require "seatsio/accounts"
require "seatsio/subaccounts"
require "seatsio/events"
require "seatsio/hold_tokens"

module Seatsio
  # Main Seatsio Class
  class Client
    attr_reader :charts, :accounts, :subaccounts, :events, :hold_tokens

    def initialize(secret_key, base_url = 'https://api.seatsio.net')
      #@client = Client.new(secret_key, base_url)
      @charts = ChartsClient.new(secret_key, base_url)
      @accounts = AccountsClient.new(secret_key, base_url)
      @subaccounts = SubaccountsClient.new(secret_key, base_url)
      @events = EventsClient.new(secret_key, base_url)
      @hold_tokens = ::Seatsio::HoldTokensClient.new(secret_key, base_url)
    end
  end
end
