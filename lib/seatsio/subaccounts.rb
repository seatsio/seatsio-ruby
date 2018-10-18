require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/domain"

module Seatsio
  class SubaccountsClient
    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, base_url)
    end

    def create(name=nil, email=nil)
      body = {}
      body['name'] = name if name
      body['email'] = email if email

      response = @http_client.post("subaccounts", body)
      Domain::Subaccount.new(response)
    end
  end
end