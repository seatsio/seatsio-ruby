require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/events/change_object_status_request"
require "seatsio/events/change_best_available_object_status_request"
require 'seatsio/channels'

module Seatsio

  class EventsClient
    attr_reader :channels

    def initialize(http_client)
      @http_client = http_client
      @channels = ChannelsClient.new(@http_client)
    end

    def create(chart_key: nil, event_key: nil, name: nil, date: nil, table_booking_config: nil, object_categories: nil, categories: nil, channels: nil, for_sale_config: nil)
      payload = build_event_request(chart_key, event_key, name, date, table_booking_config, object_categories, categories, channels: channels, is_in_the_past: nil, for_sale_config: for_sale_config)
      response = @http_client.post("events", payload)
      Event.new(response)
    end

    def create_multiple(key: nil, event_creation_params: nil)
      payload = build_events_request(chart_key: key, event_creation_params: event_creation_params)
      response = @http_client.post("events/actions/create-multiple", payload)
      Events.new(response).events
    end

    def update(key:, chart_key: nil, event_key: nil, name: nil, date: nil, table_booking_config: nil, object_categories: nil, categories: nil, is_in_the_past: nil)
      payload = build_event_request(chart_key, event_key, name, date, table_booking_config, object_categories, categories, channels: nil, is_in_the_past: is_in_the_past)
      @http_client.post("events/#{key}", payload)
    end

    def override_season_object_status(key:, objects:)
      request = {}
      request[:objects] = objects
      @http_client.post("events/#{key}/actions/override-season-status", request)
    end

    def use_season_object_status(key:, objects:)
      request = {}
      request[:objects] = objects
      @http_client.post("events/#{key}/actions/use-season-status", request)
    end

    def update_extra_data(key:, object:, extra_data: nil)
      payload = build_extra_data_request(extra_data)
      @http_client.post("events/#{key}/objects/#{object}/actions/update-extra-data", payload)
    end

    def update_extra_datas(key:, extra_data:)
      payload = build_extra_data_request(extra_data)
      @http_client.post("events/#{key}/actions/update-extra-data", payload)
    end

    def retrieve_object_info(key:, label:)
      result = retrieve_object_infos key: key, labels: [label]
      result[label]
    end

    def retrieve_object_infos(key:, labels:)
      url = "events/#{key}/objects"
      query_params = URI.encode_www_form({ label: labels })
      response = @http_client.get(url, query_params)
      response.each do |key, value|
        response[key] = EventObjectInfo.new(value)
      end
      response
    end

    def book(event_key_or_keys, object_or_objects, hold_token: nil, order_id: nil, keep_extra_data: nil, ignore_channels: nil, channel_keys: nil)
      self.change_object_status(event_key_or_keys, object_or_objects, Seatsio::EventObjectInfo::BOOKED, hold_token: hold_token, order_id: order_id, keep_extra_data: keep_extra_data, ignore_channels: ignore_channels, channel_keys: channel_keys)
    end

    def put_up_for_resale(event_key_or_keys, object_or_objects)
      self.change_object_status(event_key_or_keys, object_or_objects, Seatsio::EventObjectInfo::RESALE)
    end

    def change_object_status(event_key_or_keys, object_or_objects, status, hold_token: nil, order_id: nil, keep_extra_data: nil, ignore_channels: nil, channel_keys: nil, allowed_previous_statuses: nil, rejected_previous_statuses: nil)
      request = create_change_object_status_request(object_or_objects, status, hold_token, order_id, event_key_or_keys, keep_extra_data, ignore_channels, channel_keys, allowed_previous_statuses, rejected_previous_statuses)
      request[:params] = {
        :expand => 'objects'
      }
      response = @http_client.post("events/groups/actions/change-object-status", request)
      ChangeObjectStatusResult.new(response)
    end

    def change_object_status_in_batch(status_change_requests)
      request = {
        :statusChanges => status_change_requests,
        :params => { :expand => 'objects' }
      }
      response = @http_client.post("events/actions/change-object-status", request)
      ChangeObjectStatusInBatchResult.new(response).results
    end

    def hold(event_key_or_keys, object_or_objects, hold_token, order_id: nil, keep_extra_data: nil, ignore_channels: nil, channel_keys: nil)
      change_object_status(event_key_or_keys, object_or_objects, Seatsio::EventObjectInfo::HELD, hold_token: hold_token, order_id: order_id, keep_extra_data: keep_extra_data, ignore_channels: ignore_channels, channel_keys: channel_keys)
    end

    def change_best_available_object_status(key, number, status, categories: nil, hold_token: nil, extra_data: nil, ticket_types: nil, order_id: nil, keep_extra_data: nil, ignore_channels: nil, channel_keys: nil, try_to_prevent_orphan_seats: nil, zone: nil, accessible_seats: nil)
      request = create_change_best_available_object_status_request(number, status, categories, zone, extra_data, ticket_types, hold_token, order_id, keep_extra_data, ignore_channels, channel_keys, try_to_prevent_orphan_seats, accessible_seats)
      response = @http_client.post("events/#{key}/actions/change-object-status", request)
      BestAvailableObjects.new(response)
    end

    def book_best_available(key, number, categories: nil, hold_token: nil, order_id: nil, keep_extra_data: nil, extra_data: nil, ticket_types: nil, ignore_channels: nil, channel_keys: nil, try_to_prevent_orphan_seats: nil, zone: nil)
      change_best_available_object_status(key, number, Seatsio::EventObjectInfo::BOOKED, categories: categories, hold_token: hold_token, order_id: order_id, keep_extra_data: keep_extra_data, extra_data: extra_data, ticket_types: ticket_types, ignore_channels: ignore_channels, channel_keys: channel_keys, try_to_prevent_orphan_seats: try_to_prevent_orphan_seats, zone: zone)
    end

    def hold_best_available(key, number, hold_token, categories: nil, order_id: nil, keep_extra_data: nil, extra_data: nil, ticket_types: nil, ignore_channels: nil, channel_keys: nil, try_to_prevent_orphan_seats: nil, zone: nil)
      change_best_available_object_status(key, number, Seatsio::EventObjectInfo::HELD, categories: categories, hold_token: hold_token, order_id: order_id, keep_extra_data: keep_extra_data, extra_data: extra_data, ticket_types: ticket_types, ignore_channels: ignore_channels, channel_keys: channel_keys, try_to_prevent_orphan_seats: try_to_prevent_orphan_seats, zone: zone)
    end

    def release(event_key_or_keys, object_or_objects, hold_token: nil, order_id: nil, keep_extra_data: nil, ignore_channels: nil, channel_keys: nil)
      request = create_release_objects_request(object_or_objects, hold_token, order_id, event_key_or_keys, keep_extra_data, ignore_channels, channel_keys)
      request[:params] = {
        :expand => 'objects'
      }
      response = @http_client.post("events/groups/actions/change-object-status", request)
      ChangeObjectStatusResult.new(response)
    end

    def delete(key:)
      @http_client.delete("events/#{key}")
    end

    def retrieve(key:)
      response = @http_client.get("events/#{key}")
      Event.from_json(response)
    end

    def list
      Pagination::Cursor.new(Event, 'events', @http_client)
    end

    def list_status_changes(key, object_id = nil)
      if object_id != nil
        status_changes_for_object key: key, object_id: object_id
      else
        Pagination::Cursor.new(StatusChange, "events/#{key}/status-changes", @http_client)
      end
    end

    def status_changes_for_object(key:, object_id:)
      Pagination::Cursor.new(StatusChange, "events/#{key}/objects/#{object_id}/status-changes", @http_client)
    end

    def mark_as_not_for_sale(key:, objects: nil, area_places: nil, categories: nil)
      request = build_parameters_for_mark_as_sale objects, area_places, categories
      @http_client.post("events/#{key}/actions/mark-as-not-for-sale", request)
    end

    def mark_everything_as_for_sale(key: nil)
      @http_client.post("events/#{key}/actions/mark-everything-as-for-sale")
    end

    def mark_as_for_sale(key:, objects: nil, area_places: nil, categories: nil)
      request = build_parameters_for_mark_as_sale objects, area_places, categories
      @http_client.post("events/#{key}/actions/mark-as-for-sale", request)
    end

    private

    def build_parameters_for_mark_as_sale(objects, area_places, categories)
      request = {}
      request[:objects] = objects if objects
      request[:areaPlaces] = area_places if area_places
      request[:categories] = categories if categories
      request
    end

    def build_extra_data_request(extra_data)
      payload = {}
      payload[:extraData] = extra_data if extra_data
      payload
    end

    def build_event_request(chart_key, event_key, name, date, table_booking_config, object_categories, categories, channels: nil, is_in_the_past: nil, for_sale_config: nil)
      result = {}
      result["chartKey"] = chart_key if chart_key
      result["eventKey"] = event_key if event_key
      result["name"] = name if name
      result["date"] = date.iso8601 if date
      result["tableBookingConfig"] = table_booking_config_to_request(table_booking_config) if table_booking_config != nil
      result["objectCategories"] = object_categories if object_categories != nil
      result["categories"] = categories_to_request(categories) if categories != nil
      result["channels"] = ChannelsClient::channels_to_request(channels) if channels != nil
      result["isInThePast"] = is_in_the_past if is_in_the_past != nil
      result["forSaleConfig"] = for_sale_config_to_request(for_sale_config) if for_sale_config != nil
      result
    end

    def build_events_request(chart_key: nil, event_creation_params: nil)
      result = {}
      result["chartKey"] = chart_key
      result["events"] = event_creation_params_to_request(event_creation_params)
      result
    end

    def event_creation_params_to_request(params)
      result = []
      params.each do |param|
        r = {}
        r["eventKey"] = param[:event_key] if param[:event_key] != nil
        r["name"] = param[:name] if param[:name]
        r["date"] = param[:date].iso8601 if param[:date]
        r["tableBookingConfig"] = table_booking_config_to_request(param[:table_booking_config]) if param[:table_booking_config] != nil
        r["objectCategories"] = param[:object_categories] if param[:object_categories] != nil
        r["categories"] = categories_to_request(param[:categories]) if param[:categories] != nil
        r["channels"] = ChannelsClient::channels_to_request(param[:channels]) if param[:channels] != nil
        r["forSaleConfig"] = for_sale_config_to_request(param[:for_sale_config]) if param[:for_sale_config] != nil
        result.push(r)
      end
      result
    end

    def table_booking_config_to_request(table_booking_config)
      result = {}
      result["mode"] = table_booking_config.mode
      result["tables"] = table_booking_config.tables if table_booking_config.tables != nil
      result
    end

    def categories_to_request(categories)
      result = []
      categories.each do |category|
        r = {}
        r["key"] = category.key if category.key != nil
        r["label"] = category.label if category.label != nil
        r["color"] = category.color if category.color != nil
        r["accessible"] = category.accessible if category.accessible != nil
        result.push(r)
      end
      result
    end

    def for_sale_config_to_request(for_sale_config)
      result = {}
      result["forSale"] = for_sale_config.for_sale
      result["objects"] = for_sale_config.objects if for_sale_config.objects != nil
      result["areaPlaces"] = for_sale_config.area_places if for_sale_config.area_places != nil
      result["categories"] = for_sale_config.categories if for_sale_config.categories != nil
      result
    end

  end
end
