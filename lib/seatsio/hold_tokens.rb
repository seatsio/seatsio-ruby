require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/domain"
require "seatsio/events/change_object_status_request"

module Seatsio

  class HoldTokensClient
    # @return [Seatsio::HoldTokensClient]
    def initialize(secret_key, account_id, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, account_id, base_url)
    end

    def create(expires_in_minutes: nil)
      body = {}
      if expires_in_minutes
        body[:expiresInMinutes] = expires_in_minutes
      end
      response = @http_client.post('hold-tokens', body)
      Domain::HoldToken.new(response)
    end

    def retrieve(hold_token)
      response = @http_client.get("/hold-tokens/#{hold_token}")
      Domain::HoldToken.new(response)
    end

    def expire_in_minutes(hold_token, expires_in_minutes = nil)
      body = {"expiresInMinutes": expires_in_minutes}
      response = @http_client.post("/hold-tokens/#{hold_token}", body)
      Domain::HoldToken.new(response)
    end
  end
end
