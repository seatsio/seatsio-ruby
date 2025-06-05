require 'securerandom'

module Seatsio

  class TicketBuyersClient

    def initialize(http_client)
      @http_client = http_client
    end

    def add(ticket_buyer_id_or_ids)
      request = {}
      request['ids'] = Array(ticket_buyer_id_or_ids).compact
      response = @http_client.post("ticket-buyers", request)
      AddTicketBuyerIdsResult.new(response)
    end

    def remove(ticket_buyer_id_or_ids)
      request = {}
      request['ids'] = Array(ticket_buyer_id_or_ids).compact
      response = @http_client.delete("ticket-buyers", request)
      RemoveTicketBuyerIdsResult.new(response)
    end

    def list_all
      Pagination::Cursor.new(String, 'ticket-buyers', @http_client)
    end

  end

  class AddTicketBuyerIdsResult

    attr_reader :added, :already_present

    def initialize(data)
      @added = data['added']
      @already_present = data['alreadyPresent']
    end
  end

  class RemoveTicketBuyerIdsResult

    attr_reader :removed, :not_present

    def initialize(data)
      @removed = data['removed']
      @not_present = data['notPresent']
    end
  end
end

