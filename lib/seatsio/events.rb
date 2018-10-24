require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/domain"
require "seatsio/events/change_object_status_request"

module Seatsio

  class EventsClient
    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, base_url)
    end

    def build_event_request(chart_key, event_key=nil, book_whole_tables=nil)
      result = {}
      result["chartKey"] = chart_key if chart_key
      result["eventKey"] = event_key if event_key
      result["bookWholeTables"] = book_whole_tables if book_whole_tables
      result
    end

    def create(chart_key, event_key=nil, book_whole_tables=nil)
      payload = build_event_request(chart_key, event_key, book_whole_tables)
      response = @http_client.post("events", payload)
      Domain::Event.new(response)
    end

    def retrieve_object_status(key, object_key)
      response = @http_client.get("events/#{key}/objects/#{CGI::escape(object_key).gsub('+','%20')}")
      Domain::ObjectStatus.new(response)
    end

    def book(event_key_or_keys, object_or_objects, hold_token = nil, order_id = nil)
      self.change_object_status(event_key_or_keys, object_or_objects, Domain::ObjectStatus::BOOKED, hold_token, order_id)
    end

    def change_object_status(event_key_or_keys, object_or_objects, status, hold_token = nil, order_id = nil)
      request = create_change_object_status_request(object_or_objects, status, hold_token, order_id, event_key_or_keys)
      request[:params] = {
        'expand' => 'labels'
      }
      response = @http_client.post("seasons/actions/change-object-status", request)
      Domain::ChangeObjectStatusResult.new(response)
    end

    def hold(event_key_or_keys, object_or_objects, hold_token, order_id = nil)
      change_object_status(event_key_or_keys, object_or_objects, Domain::ObjectStatus::HELD, hold_token, order_id)
    end

  end
end
