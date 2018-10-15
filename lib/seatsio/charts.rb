require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"

module Seatsio
  class ChartsClient
    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, base_url)
    end

    def retrieve(chart_key)
      response = @http_client.get("charts/#{chart_key}")
      Domain::Chart.new(JSON.parse(response))
    end

    def retrieve_with_events(chart_key)
      response = @http_client.get("charts/#{chart_key}?expand=events")
      Domain::Chart.new(JSON.parse(response))
    end

    def build_chart_request(name=None, venue_type=None, categories=None)
      result = {}
      if name
        result["name"] = name
      end

      if venue_type
        result["venueType"] = venue_type
      end

      if categories
        result["categories"] = categories
      end
      result
    end

    def create(name=nil, venue_type=nil, categories=nil)
      payload = build_chart_request(name, venue_type, categories).to_json
      response = @http_client.post("charts", payload)
      Domain::Chart.new(JSON.parse(response))
    end

    def add_tag(key, tag)
      response = @http_client.post("charts/#{key}/tags/#{CGI::escape(tag)}", {})
    end

    def copy(key)
      response = @http_client.post("charts/#{key}/version/published/actions/copy", {})
      Domain::Chart.new(JSON.parse(response))
    end

    def retrieve_published_version(key, as_chart=true)
        response = @http_client.get("charts/#{key}/version/published")
        if as_chart
          Domain::Chart.new(JSON.parse(response))
        else
          response
        end
    end
  end
end