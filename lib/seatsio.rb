require "seatsio/version"
require "seatsio/client"

module Seatsio
  class Seatsio
    def initialize(secret_key, base_url="https://api.seatsio.net")
      @client = Client.new(secret_key, base_url)
    end

    def client
      @client
    end
  end
end
