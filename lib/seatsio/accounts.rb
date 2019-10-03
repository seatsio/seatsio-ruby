require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/domain"

module Seatsio
  class AccountsClient
    def initialize(secret_key, workspace_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, workspace_key, base_url)
    end

    def retrieve_my_account
      response = @http_client.get('accounts/me')
      Domain::Account.new(response)
    end
  end
end
