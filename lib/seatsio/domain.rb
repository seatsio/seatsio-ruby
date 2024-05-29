require 'seatsio/util'

module Seatsio

  module_function

  class Chart

    attr_reader :id, :key, :status, :name, :published_version_thumbnail_url,
                :draft_version_thumbnail_url, :events, :tags, :archived,
                :categories, :validation, :venue_type

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
      @validation = data['validation']
      @venue_type = data['venueType']
    end
  end

  class ChartValidationResult
    attr_reader :errors, :warnings

    def initialize(data)
      @errors = data['errors']
      @warnings = data['warnings']
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

    attr_reader :for_sale, :objects, :area_places, :categories

    def initialize(for_sale, objects = nil, area_places = nil, categories = nil)
      @for_sale = for_sale
      @objects = objects
      @area_places = area_places
      @categories = categories
    end

    def self.from_json(data)
      if data
        ForSaleConfig.new(data['forSale'], data['objects'], data['areaPlaces'], data['categories'])
      end
    end

    def == (other)
      other != nil &&
        for_sale == other.for_sale &&
        objects == other.objects &&
        area_places == other.area_places &&
        categories == other.categories
    end
  end

  class Category

    attr_reader :key, :label, :color, :accessible

    def initialize(key, label, color, accessible = false)
      @key = key
      @label = label
      @color = color
      @accessible = accessible
    end

    def self.from_json(data)
      if data
        Category.new(data['key'], data['label'], data['color'], data['accessible'])
      end
    end

    def self.create_list(list = [])
      result = []

      list.each do |item|
        result << Category.from_json(item)
      end

      result
    end

    def == (other)
      key == other.key &&
        label == other.label &&
        color == other.color &&
        accessible == other.accessible
    end
  end

  class TableBookingConfig

    attr_reader :mode, :tables

    def initialize(mode, tables = nil)
      @mode = mode
      @tables = tables
    end

    def self.inherit
      TableBookingConfig.new('INHERIT')
    end

    def self.all_by_seat
      TableBookingConfig.new('ALL_BY_SEAT')
    end

    def self.all_by_table
      TableBookingConfig.new('ALL_BY_TABLE')
    end

    def self.custom(tables)
      TableBookingConfig.new('CUSTOM', tables)
    end

    def self.from_json(data)
      if data
        TableBookingConfig.new(data['mode'], data['tables'])
      end
    end
  end

  class Channel
    attr_reader :key, :name, :color, :index, :objects

    def initialize(key, name, color, index, objects)
      @key = key
      @name = name
      @color = color
      @index = index
      @objects = objects
    end

    def == (other)
      key == other.key &&
        name == other.name &&
        color == other.color &&
        index == other.index &&
        objects == other.objects
    end

  end

  class Event

    attr_accessor :id, :key, :chart_key, :name, :date, :supports_best_available,
                  :table_booking_config, :for_sale_config, :created_on, :updated_on, :channels,
                  :is_top_level_season, :is_partial_season,
                  :is_event_in_season, :top_level_season_key,
                  :object_categories, :categories, :is_in_the_past, :partial_season_keys_for_event

    def initialize(data)
      @id = data['id']
      @key = data['key']
      @chart_key = data['chartKey']
      @name = data['name']
      @date = Date.iso8601(data['date']) if data['date']
      @supports_best_available = data['supportsBestAvailable']
      @table_booking_config = TableBookingConfig::from_json(data['tableBookingConfig'])
      @for_sale_config = ForSaleConfig::from_json(data['forSaleConfig']) if data['forSaleConfig']
      @created_on = parse_date(data['createdOn'])
      @updated_on = parse_date(data['updatedOn'])
      @channels = data['channels'].map {
        |d| Channel.new(d['key'], d['name'], d['color'], d['index'], d['objects'])
      } if data['channels']
      @is_top_level_season = data['isTopLevelSeason']
      @is_partial_season = data['isPartialSeason']
      @is_event_in_season = data['isEventInSeason']
      @top_level_season_key = data['topLevelSeasonKey']
      @object_categories = data['objectCategories']
      @categories = Category.create_list(data['categories']) if data['categories']
      @is_in_the_past = data['isInThePast']
      @partial_season_keys_for_event = data['partialSeasonKeysForEvent']
    end

    def is_season
      false
    end

    def self.from_json(data)
      if data['isSeason']
        Season.new(data)
      else
        Event.new(data)
      end
    end

    def self.create_list(list = [])
      result = []

      list.each do |item|
        result << Event.from_json(item)
      end

      result
    end
  end

  class Season < Event

    attr_accessor :partial_season_keys, :events

    def initialize(data)
      super(data)
      @partial_season_keys = data['partialSeasonKeys']
      @events = data['events'] ? Event.create_list(data['events']) : nil
    end

    def is_season
      true
    end
  end

  class Events
    attr_accessor :events

    def initialize(data)
      @events = Event.create_list(data['events']) if data['events']
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

  class Workspace
    attr_reader :id, :name, :key, :secret_key, :is_test, :is_active, :is_default

    def initialize(data)
      @id = data['id']
      @name = data['name']
      @key = data['key']
      @secret_key = data['secretKey']
      @is_test = data['isTest']
      @is_active = data['isActive']
      @is_default = data['isDefault']
    end
  end

  class EventLogItem
    attr_reader :id, :type, :timestamp, :data

    def initialize(data)
      @id = data['id']
      @type = data['type']
      @timestamp = DateTime.iso8601(data['timestamp'])
      @data = data['data']
    end
  end

  class ChangeObjectStatusResult

    attr_reader :objects

    def initialize(data)
      @objects = Seatsio.to_object_details(data['objects']);
    end
  end

  class ChangeObjectStatusInBatchResult

    attr_reader :results

    def initialize(data)
      @results = data['results'].map { |r| ChangeObjectStatusResult.new(r) }
    end
  end

  class HoldToken

    attr_reader :hold_token, :expires_at, :expires_in_seconds, :workspace_key

    def initialize(data)
      @hold_token = data['holdToken']
      @expires_at = Time.parse(data['expiresAt'])
      @expires_in_seconds = data['expiresInSeconds']
      @workspace_key = data['workspaceKey']
    end
  end

  class BestAvailableObjects

    attr_reader :next_to_each_other, :objects, :object_details

    def initialize(data)
      @next_to_each_other = data['nextToEachOther']
      @objects = data['objects']
      @object_details = Seatsio.to_object_details(data['objectDetails'])
    end
  end

  class ChartObjectInfo

    attr_reader :label, :labels, :ids, :category_key, :category_label, :section, :entrance, :capacity, :object_type,
                :left_neighbour, :right_neighbour, :book_as_a_whole, :distance_to_focal_point, :num_seats, :is_accessible,
                :is_companion_seat, :has_restricted_view

    def initialize(data)
      @label = data['label']
      @labels = data['labels']
      @ids = data['ids']
      @category_label = data['categoryLabel']
      @category_key = data['categoryKey']
      @section = data['section']
      @entrance = data['entrance']
      @capacity = data['capacity']
      @object_type = data['objectType']
      @left_neighbour = data['leftNeighbour']
      @right_neighbour = data['rightNeighbour']
      @book_as_a_whole = data['bookAsAWhole']
      @distance_to_focal_point = data['distanceToFocalPoint']
      @num_seats = data['numSeats']
      @is_accessible = data['isAccessible']
      @is_companion_seat = data['isCompanionSeat']
      @has_restricted_view = data['hasRestrictedView']
    end
  end

  class ChartReport

    attr_reader :items

    def initialize(data)
      items = {}
      data.each do |key, values|
        items[key] = []
        values.each do |value|
          items[key] << ChartObjectInfo.new(value)
        end
      end
      @items = items
    end
  end

  class EventReport

    attr_reader :items

    def initialize(data)
      if data.is_a? Array
        items = []
        data.each do |item|
          items << EventObjectInfo.new(item)
        end
        @items = items
      elsif data.nil?
        @items = []
      else
        items = {}
        data.each do |key, values|
          items[key] = []
          values.each do |value|
            items[key] << EventObjectInfo.new(value)
          end
        end
        @items = items
      end
    end
  end

  class EventObjectInfo
    FREE = 'free'
    BOOKED = 'booked'
    HELD = 'reservedByToken'

    attr_reader :labels, :ids, :label, :order_id, :extra_data, :capacity, :status,
                :category_key, :entrance, :object_type, :hold_token, :category_label,
                :ticket_type, :num_booked, :num_free, :num_held, :for_sale, :section,
                :is_accessible, :is_companion_seat, :has_restricted_view, :displayed_object_type,
                :left_neighbour, :right_neighbour, :is_available, :channel,
                :book_as_a_whole, :distance_to_focal_point, :holds, :num_seats,
                :variable_occupancy, :min_occupancy, :max_occupancy, :season_status_overridden_quantity

    def initialize(data)
      @status = data['status']
      @label = data['label']
      @labels = data['labels']
      @ids = data['ids']
      @category_label = data['categoryLabel']
      @category_key = data['categoryKey']
      @ticket_type = data['ticketType']
      @order_id = data['orderId']
      @for_sale = data['forSale']
      @hold_token = data['holdToken']
      @section = data['section']
      @entrance = data['entrance']
      @num_booked = data['numBooked']
      @num_free = data['numFree']
      @num_held = data['numHeld']
      @capacity = data['capacity']
      @object_type = data['objectType']
      @extra_data = data['extraData']
      @is_accessible = data['isAccessible']
      @is_companion_seat = data['isCompanionSeat']
      @has_restricted_view = data['hasRestrictedView']
      @displayed_object_type = data['displayedObjectType']
      @left_neighbour = data['leftNeighbour']
      @right_neighbour = data['rightNeighbour']
      @is_available = data['isAvailable']
      @channel = data['channel']
      @book_as_a_whole = data['bookAsAWhole']
      @distance_to_focal_point = data['distanceToFocalPoint']
      @holds = data['holds']
      @num_seats = data['numSeats']
      @variable_occupancy = data['variableOccupancy']
      @min_occupancy = data['minOccupancy']
      @max_occupancy = data['maxOccupancy']
      @season_status_overridden_quantity = data['seasonStatusOverriddenQuantity']
    end
  end

  class UsageSummaryForAllMonths
    attr_reader :usage_cutoff_date, :usage

    def initialize(data)
      usage = []
      data['usage'].each do |item|
        usage << UsageSummaryForMonth.new(item)
      end
      @usage = usage
      @usage_cutoff_date =  DateTime.iso8601(data['usageCutoffDate'])
    end
  end

  class UsageSummaryForMonth

    attr_reader :month, :num_used_objects

    def initialize(data)
      @month = Month.from_json(data['month'])
      @num_used_objects = data['numUsedObjects']
    end
  end

  class UsageDetails

    attr_reader :workspace, :usage_by_chart

    def initialize(data)
      @workspace = data['workspace']
      @usage_by_chart = data['usageByChart'].map { |usage| UsageByChart.new(usage) }
    end
  end

  class UsageByChart

    attr_reader :chart, :usage_by_event

    def initialize(data)
      @chart = data['chart'] ? UsageChart.new(data['chart']) : nil
      @usage_by_event = data['usageByEvent'].map { |usage| UsageByEvent.new(usage) }
    end
  end

  class UsageChart

    attr_reader :name, :key

    def initialize(data)
      @name = data['name']
      @key = data['key']
    end
  end

  class UsageByEvent

    attr_reader :event, :num_used_objects, :num_first_bookings, :num_object_selections

    def initialize(data)
      @event = UsageEvent.new(data['event'])
      @num_used_objects = data['numUsedObjects']
    end
  end

  class UsageEvent

    attr_reader :id, :key

    def initialize(data)
      @id = data['id']
      @key = data['key']
    end
  end

  class UsageForObjectV1

    attr_reader :object, :num_first_bookings, :first_booking_date, :num_first_selections, :num_first_bookings_or_selections

    def initialize(data)
      @object = data['object']
      @num_first_bookings = data['numFirstBookings']
      @first_booking_date = data['firstBookingDate'] ? DateTime.iso8601(data['firstBookingDate']) : nil
      @num_first_selections = data['numFirstSelections']
      @num_first_bookings_or_selections = data['numFirstBookingsOrSelections']
    end
  end

  class UsageForObjectV2

    attr_reader :object, :num_used_objects, :usage_by_reason

    def initialize(data)
      @object = data['object']
      @num_used_objects = data['numUsedObjects']
      @usage_by_reason = data['usageByReason']
    end
  end

  class Month

    attr_reader :year, :month

    def self.from_json(data)
      return Month.new(data['year'], data['month'])
    end

    def initialize(year, month)
      @year = year
      @month = month
    end

    def serialize
      @year.to_s + "-" + @month.to_s.rjust(2, "0")
    end
  end

  class StatusChange
    attr_reader :extra_data, :object_label, :date, :id, :status, :event_id, :origin, :order_id, :quantity, :hold_token,
                :is_present_on_chart, :not_present_on_chart_reason

    def initialize(data)
      @id = data['id']
      @status = data['status']
      @date = DateTime.iso8601(data['date'])
      @object_label = data['objectLabel']
      @event_id = data['eventId']
      @extra_data = data['extraData']
      @origin = StatusChangeOrigin.new(data['origin'])
      @order_id = data['orderId']
      @quantity = data['quantity']
      @hold_token = data['holdToken']
      @is_present_on_chart = data['isPresentOnChart']
      @not_present_on_chart_reason = data['notPresentOnChartReason']
    end
  end

  class StatusChangeOrigin
    attr_reader :type, :ip

    def initialize(data)
      @type = data['type']
      @ip = data['ip']
    end
  end

  def to_object_details(data)
    object_details = {}
    data.each do |key, value|
      object_details[key] = EventObjectInfo.new(value)
    end
    object_details
  end
end
