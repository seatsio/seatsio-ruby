require "seatsio/util"

module Seatsio::Domain
  class Chart

    attr_reader :id, :key, :status, :name, :published_version_thumbnail_url,
                :draft_version_thumbnail_url, :events, :tags, :archived, :venue_type

    def initialize(data)
      @id = data["id"]
      @key = data["key"]
      @status = data["status"]
      @name = data["name"]
      @published_version_thumbnail_url = data["publishedVersionThumbnailUrl"]
      @draft_version_thumbnail_url = data["draftVersionThumbnailUrl"]
      @events = Event.create_list(data["events"])
      @tags = data["tags"]
      @archived = data["archived"]
      @venue_type = data["venueType"]

    end
  end

  class Event
    def initialize(data)
      @id = data["id"]
      @key = data["key"]
      @chart_key = data["chartKey"]
      @book_whole_tables = data["bookWholeTables"]
      @supports_best_available = data["supportsBestAvailable"]
      #@for_sale_config = ForSaleConfig.create(data.get("forSaleConfig"))
      @created_on = parse_date(data["createdOn"])
      @updated_on = parse_date(data["updatedOn"])
    end

    def self.create_list(list)
      result = []
      for item in result
        result.append(Event.new(item))
      end
      return result
    end
  end

  class Subaccount

    attr_reader :id, :secret_key, :designer_key, :public_key, :name, :email, :active

    def initialize(data)
      @id = data["id"]
      @secret_key = data["secretKey"]
      @designer_key = data["designerKey"]
      @public_key = data["publicKey"]
      @name = data["name"]
      @email = data["email"]
      @active = data["active"]
    end
  end
end