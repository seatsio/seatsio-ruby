require 'seatsio/exception'

module Seatsio::Pagination
  # Enumerable for every Domain
  class Cursor
    include Enumerable

    attr_reader :params, :next_page_starts_after, :previous_page_ends_before

    MAX = 20

    def initialize(cls, endpoint, http_client, params = {})
      @cls = cls
      @endpoint = endpoint
      @http_client = http_client
      @params = params

      @collection = []

      #@start_after_id = params.fetch(:start_after_id, nil)
      #@start_before_id = params.fetch(:start_before_id, nil)
      #@limit = params.fetch(:limit, MAX)

      @next_page_starts_after = nil
      @previous_page_ends_before = nil

      @first_page = false
    end

    def each(start = 0)
      return to_enum(:each, start) unless block_given?

      Array(@collection[start..-1]).each do |element|
        yield(element)
      end

      return if @first_page and @collection.size > 0
      return if params[:limit] != nil and @collection.size > 0
      return if @params.include?(:end_before_id) and @collection.size > 0

      unless last?
        start = [@collection.size, start].max

        fetch_next_page

        each(start, &Proc.new)
      end
    end

    def fetch_next_page
      begin
        response = @http_client.get(@endpoint, @params)
        @next_page_starts_after = response["next_page_starts_after"].to_i if response["next_page_starts_after"]
        @previous_page_ends_before = response["previous_page_ends_before"].to_i if response["previous_page_ends_before"]
        items = response["items"]
        parsed_items = []

        items.each do |item|
          parsed_items.append(@cls.new(item))
        end

        #@last_response_empty = response.empty?
        @collection += parsed_items
        set_query_param(:start_after_id, items.last['id']) unless last?
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

    def first_page(limit = nil)
      @first_page = true
      set_query_param(:limit, limit) if limit != nil
      self
    end

    def page_after(after_id = nil, limit = nil)
      set_query_param(:start_after_id, after_id) if after_id != nil
      set_query_param(:limit, limit) if limit != nil
      self
    end

    def page_before(before_id = nil, limit = nil)
      set_query_param(:end_before_id, before_id) if before_id != nil
      set_query_param(:limit, limit) if limit != nil
      self
    end
  end
end
