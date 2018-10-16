require 'seatsio/version'
require 'seatsio/client'

module Seatsio
  # Main Seatsio Class
  class Seatsio
    attr_reader :client

    def initialize(secret_key, base_url = 'https://api.seatsio.net')
      @client = Client.new(secret_key, base_url)
    end
  end
end
