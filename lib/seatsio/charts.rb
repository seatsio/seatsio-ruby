require 'seatsio/exception'
require 'base64'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'seatsio/pagination/cursor'
require 'json'
require 'cgi'

module Seatsio
  class ChartsClient

    attr_reader :archive

    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, base_url)
      @archive = Pagination::Cursor.new(Domain::Chart, 'charts/archive', @http_client)
    end

    def retrieve(chart_key)
      response = @http_client.get("charts/#{chart_key}")
      Domain::Chart.new(response)
    end

    def retrieve_with_events(chart_key)
      response = @http_client.get("charts/#{chart_key}?expand=events")
      Domain::Chart.new(response)
    end

    def build_chart_request(name=nil, venue_type=nil, categories=nil)
      result = {}
      result['name'] = name if name
      result['venueType'] = venue_type if venue_type
      result['categories'] = categories if categories
      result
    end

    def create(name=nil, venue_type=nil, categories=nil)
      payload = build_chart_request(name, venue_type, categories)
      response = @http_client.post('charts', payload)
      Domain::Chart.new(response)
    end

    def update(key, new_name=nil, categories=nil)
      payload = build_chart_request(name=new_name, categories=categories)
      response = @http_client.post("charts/#{key}", payload)
    end

    def add_tag(key, tag)
      @http_client.post("charts/#{key}/tags/#{CGI::escape(tag)}")
    end

    def remove_tag(key, tag)
      @http_client.delete("charts/#{key}/tags/#{tag}")
    end

    def copy(key)
      response = @http_client.post("charts/#{key}/version/published/actions/copy")
      Domain::Chart.new(response)
    end

    def copy_to_subaccount(chart_key, subaccount_id)
      response = @http_client.post("charts/#{chart_key}/version/published/actions/copy-to/#{subaccount_id}")
      Domain::Chart.new(response)
    end

    def copy_draft_version(key)
      response = @http_client.post("charts/#{key}/version/draft/actions/copy")
      Domain::Chart.new(response)
    end

    def retrieve_published_version(key, as_chart = true)
      response = @http_client.get("charts/#{key}/version/published")
      if as_chart
        Domain::Chart.new(response)
      else
        response
      end
    end

    def discard_draft_version(key)
      @http_client.post("/charts/#{key}/version/draft/actions/discard")
    end

    def publish_draft_version(chart_key)
      @http_client.post("charts/#{chart_key}/version/draft/actions/publish")
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

    def list_first_page(page_size = nil)
      cursor = list
      cursor.set_query_param('limit', page_size)
      cursor
    end

    def list_all_tags
      response = @http_client.get('charts/tags')
      response["tags"]
    end

    def move_to_archive(chart_key)
      @http_client.post("charts/#{chart_key}/actions/move-to-archive")
    end

    def move_out_of_archive(chart_key)
      @http_client.post("charts/#{chart_key}/actions/move-out-of-archive")
    end
  end
end