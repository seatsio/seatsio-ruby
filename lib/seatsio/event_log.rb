require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"

module Seatsio
  class EventLogClient

    def initialize(http_client)
      @http_client = http_client
    end

    def list(filter: nil)
      extended_cursor = cursor
      extended_cursor.set_query_param('filter', filter)
      extended_cursor
    end

    private

    def cursor()
      Pagination::Cursor.new(EventLogItem, 'event-log', @http_client)
    end
  end
end
