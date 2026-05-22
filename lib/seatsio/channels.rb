module Seatsio

  class ChannelsClient
    def initialize(http_client)
      @http_client = http_client
    end

    def add(event_key:, channel_key:, channel_name:, channel_color:, index: nil, objects: nil, area_places: nil)
      payload = {
        key: channel_key,
        name: channel_name,
        color: channel_color
      }
      payload['index'] = index if index != nil
      payload['objects'] = objects if objects != nil
      payload['areaPlaces'] = area_places if area_places != nil
      @http_client.post("events/#{event_key}/channels", payload)
    end

    def add_multiple(event_key:, channel_creation_properties:)
      @http_client.post("events/#{event_key}/channels", channel_creation_properties)
    end

    def remove(event_key:, channel_key:)
      @http_client.delete("events/#{event_key}/channels/#{channel_key}")
    end

    def update(event_key:, channel_key:, channel_name: nil, channel_color: nil, objects: nil, area_places: nil)
      payload = {}
      payload['name'] = channel_name if channel_name != nil
      payload['color'] = channel_color if channel_color != nil
      payload['objects'] = objects if objects != nil
      payload['areaPlaces'] = area_places if area_places != nil
      @http_client.post("events/#{event_key}/channels/#{channel_key}", payload)
    end

    def add_objects(event_key:, channel_key:, objects: nil, area_places: nil)
      payload = {}
      payload['objects'] = objects if objects != nil
      payload['areaPlaces'] = area_places if area_places != nil
      @http_client.post("events/#{event_key}/channels/#{channel_key}/objects", payload)
    end

    def remove_objects(event_key:, channel_key:, objects: nil, area_places: nil)
      payload = {}
      payload['objects'] = objects if objects != nil
      payload['areaPlaces'] = area_places if area_places != nil
      @http_client.delete("events/#{event_key}/channels/#{channel_key}/objects", payload)
    end

    def replace(key:, channels:)
      @http_client.post("events/#{key}/channels/replace", { channels: ChannelsClient::channels_to_request(channels) })
    end

    def self.channels_to_request(channels)
      result = []
      channels.each do |channel|
        ch = channel.transform_keys(&:to_s)
        r = {}
        r["key"] = ch["key"]
        r["name"] = ch["name"]
        r["color"] = ch["color"]
        r["index"] = ch["index"] if ch["index"] != nil
        r["objects"] = ch["objects"] if ch["objects"] != nil
        r["areaPlaces"] = ch["areaPlaces"] || ch["area_places"] if (ch["areaPlaces"] || ch["area_places"]) != nil
        result.push(r)
      end
      result
    end

    private

  end
end
