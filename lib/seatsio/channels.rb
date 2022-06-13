module Seatsio

  class ChannelsClient
    def initialize(http_client)
      @http_client = http_client
    end

    def replace(key:, channels:)
      @http_client.post("events/#{key}/channels/update", channels: channels)
    end

    def set_objects(key:, channelConfig:)
      @http_client.post("events/#{key}/channels/assign-objects", channelConfig: channelConfig)
    end

  end
end
