require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/domain"

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
  end
end