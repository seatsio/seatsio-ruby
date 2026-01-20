require "rest-client"
require "seatsio/exception"
require "base64"
require "cgi"
require "uri"

module Seatsio
  class HttpClient
    def initialize(secret_key, workspace_key, base_url, max_retries)
      @secret_key = Base64.encode64(secret_key)
      @workspace_key = workspace_key
      @base_url = base_url
      @max_retries = max_retries
    end

    def execute(*args)
      begin
        headers = { :Authorization => "Basic #{@secret_key}" }
        headers[:'X-Client-Lib'] = "ruby"
        unless @workspace_key.nil?
          headers[:'X-Workspace-Key'] = @workspace_key
        end

        url = "#{@base_url}/#{args[1]}"

        if args[2].include? :params
          params = args[2][:params]
          if params.is_a? Hash
            headers[:params] = params
          else
            url += "?" + params
          end
        end

        request_options = { method: args[0], url: url, headers: headers, timeout: 10 }

        if args[0] == :post || args[0] == :delete
          args[2].delete :params
          request_options[:payload] = args[2].to_json
        end

        response = execute_with_retries(request_options)

        # If RAW
        if args[3]
          return response
        end
        JSON.parse(response) unless response.empty?
      rescue RestClient::NotFound => e
        raise Exception::NotFoundException.new(e.response)
      rescue RestClient::Exceptions::Timeout
        raise Exception::SeatsioException.new("Timeout ERROR")
      rescue RestClient::ExceptionWithResponse => e
        handle_exception(e.response)
      rescue SocketError
        raise Exception::SeatsioException.new("Failed to connect to backend")
      end
    end

    def execute_with_retries(request_options)
      retry_count = 0
      while true
        begin
          return RestClient::Request.execute(request_options)
        rescue RestClient::Exceptions::Timeout
          raise
        rescue RestClient::ExceptionWithResponse => e
          if e.response&.code != 429 || retry_count >= @max_retries
            raise e
          else
            wait_time = (2 ** (retry_count + 2)) / 10.0
            sleep(wait_time)
            retry_count += 1
          end
        end
      end
    end

    def get_raw(endpoint, params = {})
      execute(:get, endpoint, params, true)
    end

    def get(endpoint, params = {})
      payload = { :params => params }
      execute(:get, endpoint, payload)
    end

    def post(endpoint, payload = {})
      execute(:post, endpoint, payload)
    end

    def delete(endpoint, payload = {})
      execute(:delete, endpoint, payload)
    end

    private

    def handle_exception(response)
      if response.code == 429
        raise Exception::RateLimitExceededException.new(response)
      end

      content_type = response.headers[:content_type]
      if content_type&.include?("application/json")
        parsed_exception = JSON.parse(response.body, symbolize_names: true)
        if best_available_objects_not_found?(parsed_exception[:errors])
          raise Exception::BestAvailableObjectsNotFoundException.new(response)
        else
          raise Exception::SeatsioException.new(response)
        end
      else
        raise Exception::SeatsioException.new(response)
      end
    end

    def best_available_objects_not_found?(errors)
      errors.any? { |error| error[:code] == "BEST_AVAILABLE_OBJECTS_NOT_FOUND" }
    end

  end
end
