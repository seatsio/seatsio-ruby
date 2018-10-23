require 'seatsio/version'
#require 'seatsio/client'
require "seatsio/charts"
require "seatsio/accounts"
require "seatsio/subaccounts"
require "seatsio/events"

module Seatsio
  # Main Seatsio Class
  class Seatsio
    attr_reader :charts, :accounts, :subaccounts, :events

    def initialize(secret_key, base_url = 'https://api.seatsio.net')
      #@client = Client.new(secret_key, base_url)
      @charts = ::Seatsio::ChartsClient.new(secret_key, base_url)
      @accounts = ::Seatsio::AccountsClient.new(secret_key, base_url)
      @subaccounts = ::Seatsio::SubaccountsClient.new(secret_key, base_url)
      @events = ::Seatsio::EventsClient.new(secret_key, base_url)
    end
  end
end
