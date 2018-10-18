require "rest-client"
require "seatsio/exception"
require "base64"
require "cgi"
require "uri"

module Seatsio
  class HttpClient
    def initialize(secret_key, base_url)
      @secret_key = Base64.encode64(secret_key)
      @base_url = base_url
    end

    def get(endpoint, params = {})
      begin
        headers = {:params => params, :Authorization => "Basic #{@secret_key}"}
        url = "#{@base_url}/#{endpoint}"
        response = RestClient.get(url, headers)
        JSON.parse(response)
      rescue RestClient::ExceptionWithResponse => e
        if e.response.include? "there is no page after" || e.response.empty?
          raise Exception::NoMorePagesException
        end
      rescue RestClient::Exceptions::Timeout
        raise Exception::SeatsioException.new("Timeout ERROR")
      rescue RestClient::NotFound
        raise Exception::SeatsioException.new("Error Not Found")
      rescue SocketError
        raise Exception::SeatsioException.new("Failed to connect to backend")
      end
    end

    def post(endpoint, payload = {})
      begin
        url = @base_url + "/" + endpoint
        response = RestClient.post url, payload, {:Authorization => 'Basic ' + @secret_key, :accept => :json}
        JSON.parse(response) unless response.empty?
      rescue RestClient::Exceptions::Timeout
        raise Exception::SeatsioException.new("Timeout ERROR")
      rescue RestClient::NotFound
        raise Exception::SeatsioException.new("Error Not Found")
      rescue SocketError
        raise Exception::SeatsioException.new("Failed to connect to backend")
      end
    end
  end
end