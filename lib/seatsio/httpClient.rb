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

    def execute(*args)
      begin
        headers = {:Authorization => "Basic #{@secret_key}"}

        if !args[2].empty? || args[0] == :post
          headers[:params] = args[2]
        end

        url = "#{@base_url}/#{args[1]}"

        request_options = {method: args[0], url: url, headers: headers}
        request_options[:payload] = args[2].to_json if args[0] == :post

        response = RestClient::Request.execute(request_options)
        JSON.parse(response) unless response.empty?
      rescue RestClient::ExceptionWithResponse => e
        if e.response.include? "there is no page after" || e.response.empty?
          raise Exception::NoMorePagesException
        end
        raise Exception::SeatsioException.new(e.response)
      rescue RestClient::Exceptions::Timeout
        raise Exception::SeatsioException.new("Timeout ERROR")
      rescue RestClient::NotFound
        raise Exception::SeatsioException.new("Error Not Found")
      rescue SocketError
        raise Exception::SeatsioException.new("Failed to connect to backend")
      end
    end

    def get(endpoint, params = {})
      execute(:get, endpoint, params)
    end

    def post(endpoint, payload = {})
      execute(:post, endpoint, payload)
    end

    def delete(endpoint)
      execute(:delete, endpoint, {})
    end
  end
end