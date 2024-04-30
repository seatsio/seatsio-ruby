require 'seatsio/exception'
require 'base64'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'seatsio/pagination/cursor'
require 'json'
require 'cgi'

module Seatsio
  # Seatsio Charts client
  class ChartsClient
    attr_reader :archive

    def initialize(http_client)
      @http_client = http_client
      @archive = Pagination::Cursor.new(Chart, 'charts/archive', @http_client)
    end

    # @return [Seatsio::Chart]
    def retrieve(chart_key)
      response = @http_client.get("charts/#{chart_key}")
      Chart.new(response)
    end

    def retrieve_with_events(chart_key)
      response = @http_client.get("charts/#{chart_key}?expand=events")
      Chart.new(response)
    end

    def create(name: nil, venue_type: nil, categories: nil)
      payload = build_chart_request name, venue_type, categories
      response = @http_client.post('charts', payload)
      Chart.new(response)
    end

    def update(key:, new_name: nil, categories: nil)
      payload = build_chart_request new_name, nil, categories
      @http_client.post("charts/#{key}", payload)
    end

    def add_category(key, category)
      @http_client.post("charts/#{key}/categories", category)
    end

    def remove_category(key, category_key)
      @http_client.delete("charts/#{key}/categories/#{category_key}")
    end

    def list_categories(chart_key)
      response = @http_client.get("charts/#{chart_key}/categories")
      Category.create_list(response['categories'])
    end

    def update_category(chart_key:, category_key:, label: nil, color: nil, accessible: nil)
      payload = {}
      payload['label'] = label if label != nil
      payload['color'] = color if color != nil
      payload['accessible'] = accessible if accessible != nil
      @http_client.post("/charts/#{chart_key}/categories/#{category_key}", payload)
    end

    def add_tag(key, tag)
      @http_client.post("charts/#{key}/tags/#{CGI::escape(tag)}")
    end

    def remove_tag(key, tag)
      @http_client.delete("charts/#{key}/tags/#{tag}")
    end

    def copy(key)
      response = @http_client.post("charts/#{key}/version/published/actions/copy")
      Chart.new(response)
    end

    def copy_to_workspace(chart_key, to_workspace_key)
      url = "charts/#{chart_key}/version/published/actions/copy-to-workspace/#{to_workspace_key}"
      response = @http_client.post url
      Chart.new(response)
    end

    def copy_from_workspace_to(chart_key, from_workspace_key, to_workspace_key)
      url = "charts/#{chart_key}/version/published/actions/copy/from/#{from_workspace_key}/to/#{to_workspace_key}"
      response = @http_client.post url
      Chart.new(response)
    end

    def copy_draft_version(key)
      response = @http_client.post("charts/#{key}/version/draft/actions/copy")
      Chart.new(response)
    end

    def retrieve_published_version(key)
      @http_client.get("charts/#{key}/version/published")
    end

    def retrieve_draft_version(key)
      @http_client.get("charts/#{key}/version/draft")
    end

    def retrieve_draft_version_thumbnail(key)
      @http_client.get_raw("charts/#{key}/version/draft/thumbnail")
    end

    def retrieve_published_version_thumbnail(key)
      @http_client.get_raw("charts/#{key}/version/published/thumbnail")
    end

    def discard_draft_version(key)
      @http_client.post("charts/#{key}/version/draft/actions/discard")
    end

    def publish_draft_version(chart_key)
      @http_client.post("charts/#{chart_key}/version/draft/actions/publish")
    end

    def list(chart_filter: nil, tag: nil, expand_events: nil, with_validation: false)
      cursor = Pagination::Cursor.new(Chart, 'charts', @http_client)
      cursor.set_query_param('filter', chart_filter)
      cursor.set_query_param('tag', tag)

      cursor.set_query_param('expand', 'events') if expand_events
      cursor.set_query_param('validation', with_validation) if with_validation

      cursor
    end

    def list_all_tags
      response = @http_client.get('charts/tags')
      response['tags']
    end

    def move_to_archive(chart_key)
      @http_client.post("charts/#{chart_key}/actions/move-to-archive")
    end

    def move_out_of_archive(chart_key)
      @http_client.post("charts/#{chart_key}/actions/move-out-of-archive")
    end

    def validate_published_version(chart_key)
      response = @http_client.post("charts/#{chart_key}/version/published/actions/validate")
      Seatsio::ChartValidationResult.new(response)
    end

    def validate_draft_version(chart_key)
      response = @http_client.post("charts/#{chart_key}/version/draft/actions/validate")
      Seatsio::ChartValidationResult.new(response)
    end

    private

    def build_chart_request(name, venue_type, categories)
      result = {}
      result['name'] = name if name
      result['venueType'] = venue_type if venue_type
      result['categories'] = categories if categories
      result
    end
  end
end
