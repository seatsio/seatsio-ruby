require "seatsio/util"

module Seatsio::Domain

  class ChartCategories
    attr_accessor :list, :max_category_key

    def initialize(data)
      if data
        @list = data["list"]
        @max_category_key = data["maxCategoryKey"]
      else
        @list = []
        @max_category_key = ""
      end
    end
  end

  class Chart

    attr_reader :id, :key, :status, :name, :published_version_thumbnail_url,
                :draft_version_thumbnail_url, :events, :tags, :archived, :venue_type,
                :categories

    def initialize(data)
      @id = data["id"]
      @key = data["key"]
      @status = data["status"]
      @name = data["name"]
      @published_version_thumbnail_url = data["publishedVersionThumbnailUrl"]
      @draft_version_thumbnail_url = data["draftVersionThumbnailUrl"]
      @events = Event.create_list(data["events"]) if data["events"]
      @tags = data["tags"]
      @archived = data["archived"]
      @venue_type = data["venueType"]
      @categories = ChartCategories.new(data["categories"])

    end
  end

  class ChartDraft < Chart
    attr_reader :version
    def initialize(data)
      super(data)
      @version = data["version"]
    end
  end

  class Event

    attr_accessor :id, :key, :chart_key, :book_whole_tables, :supports_best_available,
                  :created_on, :updated_on

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

    def self.create_list(list = [])
      result = []

      list.each do |item|
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

  class APIResponse

    attr_reader :next_page_starts_after, :previous_page_ends_before, :items

    def initialize(data)
      @next_page_starts_after = data.fetch('next_page_starts_after', nil).to_i
      @previous_page_ends_before = data.fetch('previous_page_ends_before', nil).to_i
      @items = data.fetch('items', [])
    end
  end
end
