require 'seatsio/exception'

module Seatsio
  module Pagination
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
        @next_page_starts_after = nil
        @previous_page_ends_before = nil
        @first_page = false
      end

      def each(start = 0)
        return to_enum(:each, start) unless block_given?

        Array(@collection[start..-1]).each do |element|
          yield(element)
        end

        return unless keep_running?
        return if last?

        start = [@collection.size, start].max
        fetch_next_page
        each(start, &Proc.new)
      end

      def set_query_param(key, value)
        @params[key] = value
      end

      def first_page(limit = nil)
        @first_page = true
        set_query_param(:limit, limit) unless limit.nil?
        self
      end

      def page_after(after_id = nil, limit = nil)
        set_query_param(:start_after_id, after_id) unless after_id.nil?
        set_query_param(:limit, limit) unless limit.nil?
        self
      end

      def page_before(before_id = nil, limit = nil)
        set_query_param(:end_before_id, before_id) unless before_id.nil?
        set_query_param(:limit, limit) unless limit.nil?
        self
      end

      private

      def last?
        @last_response_empty || @collection.size >= MAX
      end

      def keep_running?
        return false if @first_page && !@collection.empty?
        return false if !params[:limit].nil? && !@collection.empty?
        return false if @params.include?(:end_before_id) && !@collection.empty?

        true
      end

      def fetch_next_page
        response = @http_client.get(@endpoint, @params)
        @next_page_starts_after = response['next_page_starts_after'].to_i if response['next_page_starts_after']
        @previous_page_ends_before = response['previous_page_ends_before'].to_i if response['previous_page_ends_before']
        items = response['items']
        parsed_items = []

        items.each {|item| parsed_items.append(@cls.new(item))}

        @collection += parsed_items
        set_query_param(:start_after_id, items.last['id']) unless last?
      rescue Seatsio::Exception::NoMorePagesException
        @last_response_empty = true
      end
    end
  end
end
