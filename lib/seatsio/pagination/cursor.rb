require 'seatsio/exception'

module Seatsio::Pagination
  # Enumerable for every Domain
  class Cursor
    include Enumerable

    MAX = 20

    def initialize(cls, endpoint, http_client, params = {})
      @cls = cls
      @endpoint = endpoint
      @http_client = http_client
      @params = params

      @collection = []

      @start_after_id = params.fetch(:start_after_id, nil)
      @start_before_id = params.fetch(:start_before_id, nil)
      @limit = params.fetch(:limit, MAX)
    end

    def each(start = 0)
      return to_enum(:each, start) unless block_given?

      Array(@collection[start..-1]).each do |element|
        yield(element)
      end

      unless last?
        start = [@collection.size, start].max

        fetch_next_page

        each(start, &Proc.new)
      end
    end

    def fetch_next_page
      merged_params = @params
      merged_params[:start_after_id] = @start_after_id if @start_after_id
      merged_params[:start_before_id] = @start_before_id if @start_before_id
      merged_params[:limit] = @limit if @limit

      begin
        response = @http_client.get(@endpoint, merged_params)
        items = JSON.parse(response).fetch('items')
        @last_response_empty = response.empty?
        @collection += items
        @start_after_id = items.last['id'] unless last?
      rescue Seatsio::Exception::NoMorePagesException
        @last_response_empty = true
      end
    end

    def last?
      @last_response_empty || @collection.size >= MAX
    end

    def set_query_param(key, value)
      if value
        @params[key] = value
      end
    end
  end
end
