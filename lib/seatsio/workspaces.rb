require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/domain"

module Seatsio
  class WorkspacesClient
    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, nil, base_url)
    end

    def create(name:, is_test: nil)
      body = {}
      body['name'] = name
      body['isTest'] = is_test if is_test

      response = @http_client.post("workspaces", body)
      Domain::Workspace.new(response)
    end

    def update(key:, name:)
      body = {}
      body['name'] = name
      @http_client.post("workspaces/#{key}", body)
    end

    def list()
      return cursor
    end

    def retrieve(key:)
      response = @http_client.get("/workspaces/#{key}")
      Domain::Workspace.new(response)
    end

    private

    def cursor()
      Pagination::Cursor.new(Domain::Workspace, 'workspaces', @http_client)
    end
  end
end
