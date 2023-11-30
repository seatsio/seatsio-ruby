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

    def create(chart_key:, key: nil, number_of_events: nil, event_keys: nil,
               table_booking_config: nil, channels: nil, for_sale_config: nil)
      request = build_create_season_request(chart_key, key, number_of_events, event_keys, table_booking_config, channels, for_sale_config)
      response = @http_client.post('seasons', request)
      Season.new(response)
    end

    def create_partial_season(top_level_season_key:, partial_season_key: nil, event_keys: nil)
      request = {}
      request['key'] = partial_season_key if partial_season_key
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

    def build_create_season_request(chart_key, key, number_of_events, event_keys, table_booking_config, channels, for_sale_config)
      request = {}
      request['chartKey'] = chart_key if chart_key
      request['key'] = key if key
      request['numberOfEvents'] = number_of_events if number_of_events
      request['eventKeys'] = event_keys if event_keys
      request['tableBookingConfig'] = table_booking_config_to_request(table_booking_config) if table_booking_config != nil
      request['channels'] = ChannelsClient::channels_to_request(channels) if channels != nil
      request['forSaleConfig'] = for_sale_config_to_request(for_sale_config) if for_sale_config != nil
      request
    end

    def table_booking_config_to_request(table_booking_config)
      request = {}
      request['mode'] = table_booking_config.mode
      request['tables'] = table_booking_config.tables if table_booking_config.tables != nil
      request
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
