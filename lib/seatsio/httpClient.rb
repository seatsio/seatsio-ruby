require "rest-client"
require "seatsio/exception"
require "base64"
require "cgi"
require "uri"
require "securerandom"

module Seatsio
  class HttpClient
    IDEMPOTENCY_KEY_HEADER = :'Idempotency-Key'
    UUID_V4 = /\A\h{8}-\h{4}-4\h{3}-[89ab]\h{3}-\h{12}\z/i
    SAFE_METHODS = [:get, :head, :options, :trace].freeze
    CONNECTION_ERRORS = [
      RestClient::Exceptions::Timeout,
      RestClient::ServerBrokeConnection,
      SystemCallError,
      OpenSSL::SSL::SSLError,
      SocketError
    ].freeze
    MAX_READ_TIMEOUT_RETRIES = 1

    Settings = Struct.new(:retry_non_idempotent_requests)

    def initialize(secret_key, workspace_key, base_url, max_retries)
      @secret_key = Base64.encode64(secret_key)
      @workspace_key = workspace_key
      @base_url = base_url
      @max_retries = max_retries
      @idempotency_key = nil
      @settings = Settings.new(false)
    end

    def retry_non_idempotent_requests=(enabled)
      @settings.retry_non_idempotent_requests = enabled
    end

    def with_idempotency_key(idempotency_key)
      unless idempotency_key.is_a?(String) && UUID_V4.match?(idempotency_key)
        raise ArgumentError.new("idempotency key #{idempotency_key.inspect} is not a v4 UUID")
      end
      copy = dup
      copy.idempotency_key = idempotency_key
      copy
    end

    def execute(method, endpoint, payload = {}, raw = false)
      return do_execute(method, endpoint, payload, raw, nil) if safe_method?(method)

      idempotency_key = @idempotency_key || SecureRandom.uuid
      begin
        do_execute(method, endpoint, payload, raw, idempotency_key)
      rescue Exception::SeatsioException => e
        e.idempotency_key = idempotency_key
        raise
      rescue StandardError => e
        error = Exception::SeatsioException.new("Error while executing #{method.to_s.upcase} #{endpoint}: #{e.message}")
        error.idempotency_key = idempotency_key
        raise error
      end
    end

    def execute_with_retries(request_options)
      retry_count = 0
      read_timeout_retries = 0
      while true
        begin
          return RestClient::Request.execute(request_options)
        rescue *CONNECTION_ERRORS => e
          raise unless retry_count < @max_retries && retry_on_connection_error?(request_options[:method])
          if e.is_a?(RestClient::Exceptions::ReadTimeout)
            raise unless read_timeout_retries < MAX_READ_TIMEOUT_RETRIES
            read_timeout_retries += 1
          end
          sleep(with_jitter(backoff(retry_count)))
        rescue RestClient::ExceptionWithResponse => e
          raise unless retry_count < @max_retries && retryable_response?(e.response)
          sleep(backoff(retry_count))
        end
        retry_count += 1
      end
    end

    def get_raw(endpoint, params = {})
      payload = { :params => params }
      execute(:get, endpoint, payload, true)
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

    protected

    attr_writer :idempotency_key

    private

    def do_execute(method, endpoint, payload, raw, idempotency_key)
      begin
        headers = { :Authorization => "Basic #{@secret_key}" }
        headers[:'X-Client-Lib'] = "ruby"
        unless @workspace_key.nil?
          headers[:'X-Workspace-Key'] = @workspace_key
        end
        unless idempotency_key.nil?
          headers[IDEMPOTENCY_KEY_HEADER] = idempotency_key
        end

        url = "#{@base_url}/#{endpoint}"

        if payload.include? :params
          params = payload[:params]
          if params.is_a? Hash
            headers[:params] = params
          else
            url += "?" + params
          end
        end

        request_options = { method: method, url: url, headers: headers, timeout: 10 }

        if method == :post || method == :delete
          payload.delete :params
          request_options[:payload] = payload.to_json
        end

        response = execute_with_retries(request_options)

        # If RAW
        if raw
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

    def backoff(retry_count)
      (2 ** (retry_count + 2)) / 10.0
    end

    def with_jitter(wait_time)
      wait_time / 2 + rand * wait_time / 2
    end

    def safe_method?(method)
      SAFE_METHODS.include?(method)
    end

    def retry_on_connection_error?(method)
      @settings.retry_non_idempotent_requests && !safe_method?(method)
    end

    def retryable_response?(response)
      return false if response.nil?
      response.code == 429 || (response.code == 409 && api_error_codes(response).first == "IDEMPOTENCY_KEY_IN_USE")
    end

    def handle_exception(response)
      if response.code == 429
        raise Exception::RateLimitExceededException.new(response)
      end

      if api_error_codes(response).include?("BEST_AVAILABLE_OBJECTS_NOT_FOUND")
        raise Exception::BestAvailableObjectsNotFoundException.new(response)
      end
      raise Exception::SeatsioException.new(response)
    end

    def api_error_codes(response)
      return [] unless response.headers[:content_type]&.include?("application/json")
      parsed = JSON.parse(response.body.to_s)
      errors = parsed.is_a?(Hash) ? parsed["errors"] : nil
      return [] unless errors.is_a?(Array)
      errors.filter_map { |error| error["code"] if error.is_a?(Hash) }
    rescue JSON::ParserError
      []
    end

  end
end
