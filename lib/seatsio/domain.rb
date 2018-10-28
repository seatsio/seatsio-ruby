require 'seatsio/util'

module Seatsio::Domain

  class ChartCategories
    attr_accessor :list, :max_category_key

    def initialize(data)
      if data
        @list = data['list']
        @max_category_key = data['maxCategoryKey']
      else
        @list = []
        @max_category_key = ''
      end
    end
  end

  class Chart

    attr_reader :id, :key, :status, :name, :published_version_thumbnail_url,
                :draft_version_thumbnail_url, :events, :tags, :archived, :venue_type,
                :categories

    def initialize(data)
      @id = data['id']
      @key = data['key']
      @status = data['status']
      @name = data['name']
      @published_version_thumbnail_url = data['publishedVersionThumbnailUrl']
      @draft_version_thumbnail_url = data['draftVersionThumbnailUrl']
      @events = Event.create_list(data['events']) if data['events']
      @tags = data['tags']
      @archived = data['archived']
      @venue_type = data['venueType']
      @categories = ChartCategories.new(data['categories'])

    end
  end

  class ChartDraft < Chart
    attr_reader :version
    def initialize(data)
      super(data)
      @version = data['version']
    end
  end

  class ForSaleConfig

    attr_reader :for_sale, :objects, :categories

    def initialize(data)
      if data
        @for_sale = data['forSale']
        @objects = data['objects']
        @categories = data['categories']
      end
    end
  end

  class Event

    attr_accessor :id, :key, :chart_key, :book_whole_tables, :supports_best_available,
                  :table_booking_modes, :for_sale_config, :created_on, :updated_on

    def initialize(data)
      @id = data['id']
      @key = data['key']
      @chart_key = data['chartKey']
      @book_whole_tables = data['bookWholeTables']
      @supports_best_available = data['supportsBestAvailable']
      @table_booking_modes = data['tableBookingModes']
      @for_sale_config = ForSaleConfig.new(data['forSaleConfig']) if data['forSaleConfig']
      @created_on = parse_date(data['createdOn'])
      @updated_on = parse_date(data['updatedOn'])
    end

    def self.create_list(list = [])
      result = []

      list.each do |item|
        result.append(Event.new(item))
      end

      return result
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

  class ChartValidationSettings
    attr_reader :validate_duplicate_labels, :validate_objects_without_categories,
                :validate_unlabeled_objects

    def initialize(data)
      @validate_duplicate_labels = data['VALIDATE_DUPLICATE_LABELS']
      @validate_objects_without_categories = data['VALIDATE_OBJECTS_WITHOUT_CATEGORIES']
      @validate_unlabeled_objects = data['VALIDATE_UNLABELED_OBJECTS']
    end
  end

  class AccountSettings
    attr_reader :draft_chart_drawings_enabled, :chart_validation

    def initialize(data)
      @draft_chart_drawings_enabled = data['draftChartDrawingsEnabled']
      @chart_validation = ChartValidationSettings.new(data['chartValidation'])
    end
  end

  class Account
    attr_reader :id, :secret_key, :designer_key, :public_key, :name,
                :email, :active, :settings

    def initialize(data)
      @id = data['id']
      @secret_key = data['secretKey']
      @designer_key = data['designerKey']
      @public_key = data['publicKey']
      @name = data['name']
      @email = data['email']
      @active = data['active']
      @settings = AccountSettings.new(data['settings']) if data['settings'] != nil
    end
  end

  class Subaccount < Account
  end

  class ObjectStatus
    FREE = 'free'
    BOOKED = 'booked'
    HELD = 'reservedByToken'

    attr_reader :status, :hold_token, :order_id, :ticket_type,
                :quantity, :extra_data

    def initialize(data)
      @status = data['status']
      @hold_token = data['holdToken']
      @order_id = data['orderId']
      @ticket_type = data['ticketType']
      @quantity = data['quantity']
      @extra_data = data['extraData']
    end
  end

  class ChangeObjectStatusResult

    attr_reader :labels

    def initialize(data)
      if data
        @labels = data['labels'] if data.include? 'labels'
      end
    end
  end

  class HoldToken

    attr_reader :hold_token, :expires_at, :expires_in_seconds

    def initialize(data)
      @hold_token = data['holdToken']
      @expires_at = Time.parse(data['expiresAt'])
      @expires_in_seconds = data['expiresInSeconds']
    end
  end

  class BestAvailableObjects

    attr_reader :next_to_each_other, :objects, :labels

    def initialize(data)
      @next_to_each_other = data['nextToEachOther']
      @objects = data['objects']
      @labels = data['labels']
    end
  end

  class ChartReportItem

    attr_reader :label, :labels, :category_key, :category_label, :section, :entrance, :capacity, :object_type

    def initialize(data)
      @label = data['label']
      @labels = data['labels']
      @category_label = data['categoryLabel']
      @category_key = data['categoryKey']
      @section = data['section']
      @entrance = data['entrance']
      @capacity = data['capacity']
      @object_type = data['objectType']
    end
  end

  class ChartReport

    attr_reader :items

    def initialize(data)
      items = {}
      data.each do |key, values|
        items[key] = []
        values.each do |value|
          items[key].append(ChartReportItem.new(value))
        end
      end
      @items = items
    end
  end

  class EventReport

    attr_reader :items

    #def initialize(data)
    #  items = []
    #  data.each do |item|
    #    items.append(EventReportItem.new(item))
    #  end
    #  @items = items
    #end
    def initialize(data)
      if data.is_a? Array
        items = []
        data.each do |item|
          items.append(EventReportItem.new(item))
        end
        @items = items
      else
        items = {}
        data.each do |key, values|
          items[key] = []
          values.each do |value|
            items[key].append(EventReportItem.new(value))
          end
        end
        @items = items
      end
    end
  end

  class EventReportItem
    attr_reader :labels, :label, :order_id, :extra_data, :capacity, :status,
                :category_key, :entrance, :object_type, :hold_token, :category_label,
                :ticket_type, :num_booked, :for_sale, :section

    def initialize(data)
      @status = data['status']
      @label = data['label']
      @labels = data['labels']
      @category_label = data['categoryLabel']
      @category_key = data['categoryKey']
      @ticket_type = data['ticketType']
      @order_id = data['orderId']
      @for_sale = data['forSale']
      @hold_token = data['holdToken']
      @section = data['section']
      @entrance = data['entrance']
      @num_booked = data['numBooked']
      @capacity = data['capacity']
      @object_type = data['objectType']
      @extra_data = data['extraData']
    end
  end

  class StatusChange
    attr_reader :extra_data, :object_label, :date, :id, :status, :event_id

    def initialize(data)
      @id = data['id']
      @status = data['status']
      @date = data['date']# TODO: parse_date(data.get("date"))
      @object_label = data['objectLabel']
      @event_id = data['eventId']
      @extra_data = data['extraData']
    end
  end
end
