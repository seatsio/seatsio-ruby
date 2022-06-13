module Seatsio

  class ChannelsClient
    def initialize(http_client)
      @http_client = http_client
    end

    def add(event_key:, channel_key:, channel_name:, channel_color:, index: nil, objects: nil)
      payload = {
        key: channel_key,
        name: channel_name,
        color: channel_color
      }
      payload['index'] = index if index != nil
      payload['objects'] = objects if objects != nil
      @http_client.post("events/#{event_key}/channels", payload)
    end

    def remove(event_key:, channel_key:)
      @http_client.delete("events/#{event_key}/channels/#{channel_key}")
    end

    def update(event_key:, channel_key:, channel_name: nil, channel_color: nil, objects: nil)
      payload = {}
      payload['name'] = channel_name if channel_name != nil
      payload['color'] = channel_color if channel_color != nil
      payload['objects'] = objects if objects != nil
      @http_client.post("events/#{event_key}/channels/#{channel_key}", payload)
    end

    def add_objects(event_key:, channel_key:, objects:)
      @http_client.post("events/#{event_key}/channels/#{channel_key}/objects", { objects: objects })
    end

    def remove_objects(event_key:, channel_key:, objects:)
      @http_client.delete("events/#{event_key}/channels/#{channel_key}/objects", { objects: objects })
    end

    def replace(key:, channels:)
      @http_client.post("events/#{key}/channels/update", channels: channels)
    end

    def set_objects(key:, channelConfig:)
      @http_client.post("events/#{key}/channels/assign-objects", channelConfig: channelConfig)
    end

  end
end
