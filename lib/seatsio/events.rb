require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/domain"
require "seatsio/events/change_object_status_request"
require "seatsio/events/change_best_available_object_status_request"

module Seatsio

  class EventsClient
    def initialize(secret_key, workspace_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, workspace_key, base_url)
    end

    def create(chart_key: nil, event_key: nil, book_whole_tables: nil, table_booking_modes: nil, social_distancing_ruleset_key: nil)
      payload = build_event_request(chart_key: chart_key, event_key: event_key, book_whole_tables: book_whole_tables,
                                    table_booking_modes: table_booking_modes, social_distancing_ruleset_key: social_distancing_ruleset_key)
      response = @http_client.post("events", payload)
      Domain::Event.new(response)
    end

    def create_multiple(key: nil, event_creation_params: nil)
      payload = build_events_request(chart_key: key, event_creation_params: event_creation_params)
      response = @http_client.post("events/actions/create-multiple", payload)
      Domain::Events.new(response).events
    end

    def update(key:, chart_key: nil, event_key: nil, book_whole_tables: nil, table_booking_modes: nil, social_distancing_ruleset_key: nil)
      payload = build_event_request(chart_key: chart_key, event_key: event_key, book_whole_tables: book_whole_tables,
                                    table_booking_modes: table_booking_modes, social_distancing_ruleset_key: social_distancing_ruleset_key)
      @http_client.post("/events/#{key}", payload)
    end

    def update_extra_data(key:, object:, extra_data: nil)
      payload = build_extra_data_request(extra_data)
      @http_client.post("events/#{key}/objects/#{object}/actions/update-extra-data", payload)
    end

    def update_extra_datas(key:, extra_data:)
      payload = build_extra_data_request(extra_data)
      @http_client.post("events/#{key}/actions/update-extra-data", payload)
    end

    def retrieve_object_status(key:, object_key:)
      url = "events/#{key}/objects/#{CGI::escape(object_key).gsub('+', '%20')}"
      response = @http_client.get(url)
      Domain::ObjectStatus.new(response)
    end

    # @param [Object] event_key_or_keys
    # @param [Object] object_or_objects
    # @param [Object] hold_token
    # @param [Object] order_id
    def book(event_key_or_keys, object_or_objects, hold_token = nil, order_id = nil, keep_extra_data = nil)
      self.change_object_status(event_key_or_keys, object_or_objects, Domain::ObjectStatus::BOOKED, hold_token, order_id, keep_extra_data)
    end

    def change_object_status(event_key_or_keys, object_or_objects, status, hold_token = nil, order_id = nil, keep_extra_data = nil)
      request = create_change_object_status_request(object_or_objects, status, hold_token, order_id, event_key_or_keys, keep_extra_data)
      request[:params] = {
          :expand => 'objects'
      }
      response = @http_client.post("seasons/actions/change-object-status", request)
      Domain::ChangeObjectStatusResult.new(response)
    end

    def change_object_status_in_batch(status_change_requests)
      request = {
          :statusChanges => status_change_requests,
          :params => { :expand => 'objects' }
      }
      response = @http_client.post("events/actions/change-object-status", request)
      Domain::ChangeObjectStatusInBatchResult.new(response).results
    end

    def hold(event_key_or_keys, object_or_objects, hold_token, order_id = nil, keep_extra_data = nil)
      change_object_status(event_key_or_keys, object_or_objects, Domain::ObjectStatus::HELD, hold_token, order_id, keep_extra_data)
    end

    def change_best_available_object_status(key, number, status, categories: nil, hold_token: nil, extra_data: nil, order_id: nil, keep_extra_data: nil)
      request = create_change_best_available_object_status_request(number, status, categories, extra_data, hold_token, order_id, keep_extra_data)
      response = @http_client.post("events/#{key}/actions/change-object-status", request)
      Domain::BestAvailableObjects.new(response)
    end

    def book_best_available(key, number, categories: nil, hold_token: nil, order_id: nil, keep_extra_data: nil, extra_data: nil)
      change_best_available_object_status(key, number, Domain::ObjectStatus::BOOKED, categories: categories, hold_token: hold_token, order_id: order_id, keep_extra_data: keep_extra_data, extra_data: extra_data)
    end

    def hold_best_available(key, number, hold_token, categories: nil, order_id: nil, keep_extra_data: nil, extra_data: nil)
      change_best_available_object_status(key, number, Domain::ObjectStatus::HELD, categories: categories, hold_token: hold_token, order_id: order_id, keep_extra_data: keep_extra_data, extra_data: extra_data)
    end

    def release(event_key_or_keys, object_or_objects, hold_token = nil, order_id = nil, keep_extra_data = nil)
      change_object_status(event_key_or_keys, object_or_objects, Domain::ObjectStatus::FREE, hold_token, order_id, keep_extra_data)
    end

    def delete(key:)
      @http_client.delete("/events/#{key}")
    end


    def retrieve(key:)
      response = @http_client.get("events/#{key}")
      Domain::Event.new(response)
    end

    def list
      Pagination::Cursor.new(Domain::Event, 'events', @http_client)
    end

    def list_status_changes(key, object_id = nil)
      if object_id != nil
        status_changes_for_object key: key, object_id: object_id
      else
        Pagination::Cursor.new(Domain::StatusChange, "/events/#{key}/status-changes", @http_client)
      end
    end

    def status_changes_for_object(key:, object_id:)
      Pagination::Cursor.new(Domain::StatusChange, "/events/#{key}/objects/#{object_id}/status-changes", @http_client)
    end

    def mark_as_not_for_sale(key:, objects: nil, categories: nil)
      request = build_parameters_for_mark_as_sale objects: objects, categories: categories
      @http_client.post("events/#{key}/actions/mark-as-not-for-sale", request)
    end

    def mark_everything_as_for_sale(key: nil)
      @http_client.post("events/#{key}/actions/mark-everything-as-for-sale")
    end

    def mark_as_for_sale(key:, objects: nil, categories: nil)
      request = build_parameters_for_mark_as_sale objects: objects, categories: categories
      @http_client.post("events/#{key}/actions/mark-as-for-sale", request)
    end

    def update_channels(key:, channels:)
      @http_client.post("events/#{key}/channels/update", channels: channels)
    end

    def assign_objects_to_channels(key:, channelConfig:)
      @http_client.post("events/#{key}/channels/assign-objects", channelConfig: channelConfig)
    end

    private

    def build_parameters_for_mark_as_sale(objects: nil, categories: nil)
      request = {}
      request[:objects] = objects if objects
      request[:categories] = categories if categories
      request
    end

    def build_extra_data_request(extra_data)
      payload = {}
      payload[:extraData] = extra_data if extra_data
      payload
    end

    def build_event_request(chart_key: nil, event_key: nil, book_whole_tables: nil, table_booking_modes: nil, social_distancing_ruleset_key: nil)
      result = {}
      result["chartKey"] = chart_key if chart_key
      result["eventKey"] = event_key if event_key
      result["bookWholeTables"] = book_whole_tables if book_whole_tables != nil
      result["tableBookingModes"] = table_booking_modes if table_booking_modes != nil
      result["socialDistancingRulesetKey"] = social_distancing_ruleset_key if social_distancing_ruleset_key != nil
      result
    end

    def build_events_request(chart_key: nil, event_creation_params: nil)
      result = {}
      result["chartKey"] = chart_key
      result["events"] = event_creation_params_to_request(params: event_creation_params)
      result
    end

    def event_creation_params_to_request(params: nil)
      result = []
      params.each do |param|
        r = {}
        r["eventKey"] = param[:event_key] if param[:event_key] != nil
        r["bookWholeTables"] = param[:book_whole_tables] if param[:book_whole_tables] != nil
        r["tableBookingModes"] = param[:table_booking_modes] if param[:table_booking_modes] != nil
        result.push(r)
      end
      result
    end

  end
end
