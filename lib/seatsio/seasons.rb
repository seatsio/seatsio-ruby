require 'seatsio/exception'
require 'base64'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio

  class SeasonsClient
    def initialize(http_client, seatsio_client)
      @http_client = http_client
      @seatsio_client = seatsio_client
    end

    def create(chart_key:, key: nil, name: nil, number_of_events: nil, event_keys: nil,
               table_booking_config: nil, object_categories: nil, categories: nil, channels: nil,
               for_sale_config: nil, for_sale_propagated: nil)
      request = build_create_season_request(chart_key, key, name, number_of_events, event_keys, table_booking_config, object_categories, categories, channels, for_sale_config, for_sale_propagated)
      response = @http_client.post('seasons', request)
      Season.new(response)
    end

    def update(key:, event_key: nil, name: nil, table_booking_config: nil, object_categories: nil, categories: nil, for_sale_propagated: nil)
      payload = build_update_season_request(event_key, name, table_booking_config, object_categories, categories, for_sale_propagated)
      @http_client.post("events/#{key}", payload)
    end

    def create_partial_season(top_level_season_key:, partial_season_key: nil, name: nil, event_keys: nil)
      request = {}
      request['key'] = partial_season_key if partial_season_key
      request['name'] = name if name
      request['eventKeys'] = event_keys if event_keys
      response = @http_client.post("seasons/#{top_level_season_key}/partial-seasons", request)
      Season.new(response)
    end

    def retrieve(key:)
      @seatsio_client.events.retrieve(key: key)
    end

    def create_events(key:, number_of_events: nil, event_keys: nil)
      request = {}
      request['eventKeys'] = event_keys if event_keys
      request['numberOfEvents'] = number_of_events if number_of_events
      response = @http_client.post("seasons/#{key}/actions/create-events", request)
      Events.new(response).events
    end

    def add_events_to_partial_season(top_level_season_key:, partial_season_key:, event_keys:)
      request = {}
      request['eventKeys'] = event_keys
      response = @http_client.post("seasons/#{top_level_season_key}/partial-seasons/#{partial_season_key}/actions/add-events", request)
      Season.new(response)
    end

    def remove_event_from_partial_season(top_level_season_key:, partial_season_key:, event_key:)
      response = @http_client.delete("seasons/#{top_level_season_key}/partial-seasons/#{partial_season_key}/events/#{event_key}")
      Season.new(response)
    end

    private

    def build_create_season_request(chart_key, key, name, number_of_events, event_keys, table_booking_config, object_categories, categories, channels, for_sale_config, for_sale_propagated)
      request = {}
      request['chartKey'] = chart_key if chart_key
      request['key'] = key if key
      request['name'] = name if name
      request['numberOfEvents'] = number_of_events if number_of_events
      request['eventKeys'] = event_keys if event_keys
      request['tableBookingConfig'] = EventsClient::table_booking_config_to_request(table_booking_config) if table_booking_config != nil
      request["objectCategories"] = object_categories if object_categories != nil
      request["categories"] = EventsClient::categories_to_request(categories) if categories != nil
      request['channels'] = ChannelsClient::channels_to_request(channels) if channels != nil
      request['forSaleConfig'] = EventsClient::for_sale_config_to_request(for_sale_config) if for_sale_config != nil
      request['forSalePropagated'] = for_sale_propagated if for_sale_propagated != nil
      request
    end

    def build_update_season_request(key, name, table_booking_config, object_categories, categories, for_sale_propagated)
      request = {}
      request['eventKey'] = key if key
      request['name'] = name if name
      request['tableBookingConfig'] = EventsClient::table_booking_config_to_request(table_booking_config) if table_booking_config != nil
      request["objectCategories"] = object_categories if object_categories != nil
      request["categories"] = EventsClient::categories_to_request(categories) if categories != nil
      request['forSalePropagated'] = for_sale_propagated if for_sale_propagated != nil
      request
    end
  end
end
