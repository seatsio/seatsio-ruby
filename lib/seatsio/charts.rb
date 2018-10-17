require 'seatsio/exception'
require 'base64'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'seatsio/pagination/cursor'
require 'json'
require 'cgi'

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

    def build_chart_request(name=nil, venue_type=nil, categories=nil)
      result = {}
      result['name'] = name if name
      result['venueType'] = venue_type if venue_type
      result['categories'] = categories if categories
      result
    end

    def create(name=nil, venue_type=nil, categories=nil)
      payload = build_chart_request(name, venue_type, categories).to_json
      response = @http_client.post('charts', payload)
      Domain::Chart.new(JSON.parse(response))
    end

    def update(key, new_name=nil, categories=nil)
      payload = build_chart_request(name=new_name, categories=categories).to_json
      response = @http_client.post("charts/#{key}", payload)
    end

    def add_tag(key, tag)
      @http_client.post("charts/#{key}/tags/#{CGI::escape(tag)}", {})
    end

    def copy(key)
      response = @http_client.post("charts/#{key}/version/published/actions/copy", {})
      Domain::Chart.new(JSON.parse(response))
    end

    def copy_to_subaccount(chart_key, subaccount_id)
      response = @http_client.post("charts/#{chart_key}/version/published/actions/copy-to/#{subaccount_id}", {})
      Domain::Chart.new(JSON.parse(response))
    end

    def copy_draft_version(key)
      response = @http_client.post("charts/#{key}/version/draft/actions/copy", {})
      Domain::Chart.new(JSON.parse(response))
    end

    def retrieve_published_version(key, as_chart = true)
      response = @http_client.get("charts/#{key}/version/published")
      if as_chart
        Domain::Chart.new(JSON.parse(response))
      else
        response
      end
    end

    def discard_draft_version(key)
      @http_client.post("/charts/#{key}/version/draft/actions/discard", {} )
    end

    def list(chart_filter = nil, tag = nil, expand_events = nil)
      cursor = Pagination::Cursor.new(Domain::Chart, 'charts', @http_client)
      cursor.set_query_param('filter', chart_filter)
      cursor.set_query_param('tag', tag)

      if expand_events
        cursor.set_query_param('expand', 'events')
      end
      cursor
    end
  end
end