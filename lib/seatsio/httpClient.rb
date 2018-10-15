require "rest-client"
require "seatsio/exception"
require "base64"
require "cgi"

module Seatsio
  class HttpClient
    def initialize(secret_key, base_url)
      @secret_key = Base64.encode64(secret_key)
      @base_url = base_url
    end

    def get(*args)
      begin
        RestClient.get @base_url + "/" + args[0], {:Authorization => 'Basic ' + @secret_key}
      rescue RestClient::Exceptions::Timeout
        raise SeatsioException.new("Timeout ERROR")
      rescue RestClient::NotFound
        raise SeatsioException.new("Error Not Found")
      rescue SocketError
        raise SeatsioException.new("Failed to connect to backend")
      end
    end

    def post(endpoint, payload)
      begin
        url = @base_url + "/" + endpoint
        RestClient.post url, payload, {:Authorization => 'Basic ' + @secret_key}
      rescue RestClient::Exceptions::Timeout
        raise SeatsioException.new("Timeout ERROR")
      rescue RestClient::NotFound
        raise SeatsioException.new("Error Not Found")
      rescue SocketError
        raise SeatsioException.new("Failed to connect to backend")
      end
    end
  end
end