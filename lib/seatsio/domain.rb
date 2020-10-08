require 'seatsio/util'

module Seatsio::Domain

  module_function

  class Chart

    attr_reader :id, :key, :status, :name, :published_version_thumbnail_url,
                :draft_version_thumbnail_url, :events, :tags, :archived,
                :categories, :validation, :social_distancing_rulesets

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
      @social_distancing_rulesets = data['socialDistancingRulesets'].map {
          |key, r| [key, SocialDistancingRuleset.new(r['name'], r['numberOfDisabledSeatsToTheSides'], r['disableSeatsInFrontAndBehind'],
                                                     r['numberOfDisabledAisleSeats'], r['maxGroupSize'],
                                                     r['maxOccupancyAbsolute'], r['maxOccupancyPercentage'], r['fixedGroupLayout'],
                                                     r['disabledSeats'], r['enabledSeats'], r['index'])]
      }.to_h
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

    attr_reader :for_sale, :objects, :categories

    def initialize(data)
      if data
        @for_sale = data['forSale']
        @objects = data['objects']
        @categories = data['categories']
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
      self.key == other.key &&
          self.name == other.name &&
          self.color == other.color &&
          self.index == other.index &&
          self.objects == other.objects
    end

  end

  class Event

    attr_accessor :id, :key, :chart_key, :book_whole_tables, :supports_best_available,
                  :table_booking_modes, :for_sale_config, :created_on, :updated_on, :channels,
                  :social_distancing_ruleset_key

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
      @channels = data['channels'].map {
          |d| Channel.new(d['key'], d['name'], d['color'], d['index'], d['objects'])
      } if data['channels']
      @social_distancing_ruleset_key = data['socialDistancingRulesetKey']
    end

    def self.create_list(list = [])
      result = []

      list.each do |item|
        result << Event.new(item)
      end

      return result
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

  class Subaccount
    attr_reader :id, :secret_key, :designer_key, :public_key, :name, :active

    def initialize(data)
      @id = data['id']
      @public_key = data['publicKey']
      @secret_key = data['secretKey']
      @designer_key = data['designerKey']
      @name = data['name']
      @active = data['active']
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

  class ObjectStatus
    FREE = 'free'
    BOOKED = 'booked'
    HELD = 'reservedByToken'

    attr_reader :status, :hold_token, :order_id, :ticket_type,
                :quantity, :extra_data, :for_sale

    def initialize(data)
      @status = data['status']
      @hold_token = data['holdToken']
      @order_id = data['orderId']
      @ticket_type = data['ticketType']
      @quantity = data['quantity']
      @extra_data = data['extraData']
      @for_sale = data['forSale']
    end
  end

  class ChangeObjectStatusResult

    attr_reader :objects

    def initialize(data)
      @objects = Seatsio::Domain.to_object_details(data['objects']);
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
      @object_details = Seatsio::Domain.to_object_details(data['objectDetails'])
    end
  end

  class ChartReportItem

    attr_reader :label, :labels, :category_key, :category_label, :section, :entrance, :capacity, :object_type,
                :left_neighbour, :right_neighbour

    def initialize(data)
      @label = data['label']
      @labels = data['labels']
      @category_label = data['categoryLabel']
      @category_key = data['categoryKey']
      @section = data['section']
      @entrance = data['entrance']
      @capacity = data['capacity']
      @object_type = data['objectType']
      @left_neighbour = data['leftNeighbour']
      @right_neighbour = data['rightNeighbour']
    end
  end

  class ChartReport

    attr_reader :items

    def initialize(data)
      items = {}
      data.each do |key, values|
        items[key] = []
        values.each do |value|
          items[key] << ChartReportItem.new(value)
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
          items << EventReportItem.new(item)
        end
        @items = items
      elsif data.nil?
        @items = []
      else
        items = {}
        data.each do |key, values|
          items[key] = []
          values.each do |value|
            items[key] << EventReportItem.new(value)
          end
        end
        @items = items
      end
    end
  end

  class EventReportItem
    attr_reader :labels, :label, :order_id, :extra_data, :capacity, :status,
                :category_key, :entrance, :object_type, :hold_token, :category_label,
                :ticket_type, :num_booked, :num_free, :num_held, :for_sale, :section,
                :is_accessible, :is_companion_seat, :has_restricted_view, :displayed_object_type,
                :left_neighbour, :right_neighbour, :is_selectable, :is_disabled_by_social_distancing, :channel

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
      @is_selectable = data['isSelectable']
      @is_disabled_by_social_distancing = data['isDisabledBySocialDistancing']
      @channel = data['channel']
    end
  end

  class UsageSummaryForAllMoths
    attr_reader :items

    def initialize(data)
      items = []
      data.each do |item|
        items << UsageSummaryForMonth.new(item)
      end
      @items = items
    end
  end

  class UsageSummaryForMonth
    def initialize(data)
      @month = Month.from_json(data['month'])
      @num_used_objects = data['numUsedObjects']
      @num_first_bookings = data['numFirstBookings']
      @num_first_bookings_by_status = data['numFirstBookingsByStatus']
      @num_first_bookings_or_selections = data['numFirstBookingsOrSelections']
    end
  end

  class UsageDetails

    attr_reader :subaccount

    def initialize(data)
      @subaccount = data['subaccount'] ? UsageSubaccount.new(data['subaccount']) : nil
      @usage_by_chart = data['usageByChart'].map { |usage| UsageByChart.new(usage) }
    end
  end

  class UsageSubaccount

    attr_reader :id

    def initialize(data)
      @id = data['id']
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

    attr_reader :event, :num_used_objects, :num_first_bookings, :num_first_bookings_or_selections,
                :num_ga_selections_without_booking, :num_non_ga_selections_without_booking, :num_object_selections

    def initialize(data)
      @event = UsageEvent.new(data['event'])
      @num_used_objects = data['numUsedObjects']
      @num_first_bookings = data['numFirstBookings']
      @num_first_bookings_or_selections = data['numFirstBookingsOrSelections']
      @num_ga_selections_without_booking = data['numGASelectionsWithoutBooking']
      @num_non_ga_selections_without_booking = data['numNonGASelectionsWithoutBooking']
      @num_object_selections = data['numObjectSelections']
    end
  end

  class UsageEvent

    attr_reader :id, :key

    def initialize(data)
      @id = data['id']
      @key = data['key']
    end
  end

  class UsageForObject

    attr_reader :object, :num_first_bookings, :first_booking_date, :num_first_bookings, :num_first_bookings_or_selections

    def initialize(data)
      @object = data['object']
      @num_first_bookings = data['numFirstBookings']
      @first_booking_date = data['firstBookingDate'] ? DateTime.iso8601(data['firstBookingDate']) : nil
      @num_first_selections = data['numFirstSelections']
      @num_first_bookings_or_selections = data['numFirstBookingsOrSelections']
    end
  end

  class Month

    attr_reader :year, :month

    def self.from_json(data)
      @year = data['year']
      @month = data['month']
      self
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
    attr_reader :extra_data, :object_label, :date, :id, :status, :event_id, :origin, :order_id, :quantity, :hold_token

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
      object_details[key] = EventReportItem.new(value)
    end
    object_details
  end

  class SocialDistancingRuleset
    attr_reader :name, :number_of_disabled_seats_to_the_sides, :disable_seats_in_front_and_behind,
                :number_of_disabled_aisle_seats, :max_group_size, :max_occupancy_absolute,
                :max_occupancy_percentage, :fixed_group_layout, :disabled_seats, :enabled_seats, :index

    def initialize(name, number_of_disabled_seats_to_the_sides = 0, disable_seats_in_front_and_behind = false, number_of_disabled_aisle_seats = 0,
                   max_group_size = 0, max_occupancy_absolute = 0, max_occupancy_percentage = 0, fixed_group_layout = false,
                   disabled_seats = [], enabled_seats = [], index = 0)
      @name = name
      @number_of_disabled_seats_to_the_sides = number_of_disabled_seats_to_the_sides
      @disable_seats_in_front_and_behind = disable_seats_in_front_and_behind
      @number_of_disabled_aisle_seats = number_of_disabled_aisle_seats
      @max_group_size = max_group_size
      @max_occupancy_absolute = max_occupancy_absolute
      @max_occupancy_percentage = max_occupancy_percentage
      @fixed_group_layout = fixed_group_layout
      @disabled_seats = disabled_seats
      @enabled_seats = enabled_seats
      @index = index
    end

    def self.fixed(name, disabled_seats = [], index = 0)
      SocialDistancingRuleset.new(name, 0, false, 0, 0, 0, 0, true, disabled_seats, [], index)
    end

    def self.rule_based(name, number_of_disabled_seats_to_the_sides = 0, disable_seats_in_front_and_behind = false, number_of_disabled_aisle_seats = 0,
                        max_group_size = 0, max_occupancy_absolute = 0, max_occupancy_percentage = 0,
                        disabled_seats = [], enabled_seats = [], index = 0)
      SocialDistancingRuleset.new(name, number_of_disabled_seats_to_the_sides, disable_seats_in_front_and_behind, number_of_disabled_aisle_seats,
                                  max_group_size, max_occupancy_absolute, max_occupancy_percentage,
                                  false, disabled_seats, enabled_seats, index)
    end

    def == (other)
      self.name == other.name &&
          self.number_of_disabled_seats_to_the_sides == other.number_of_disabled_seats_to_the_sides &&
          self.disable_seats_in_front_and_behind == other.disable_seats_in_front_and_behind &&
          self.number_of_disabled_aisle_seats == other.number_of_disabled_aisle_seats &&
          self.max_group_size == other.max_group_size &&
          self.max_occupancy_absolute == other.max_occupancy_absolute &&
          self.max_occupancy_percentage == other.max_occupancy_percentage &&
          self.fixed_group_layout == other.fixed_group_layout &&
          self.disabled_seats == other.disabled_seats &&
          self.enabled_seats == other.enabled_seats &&
          self.index == other.index
    end
  end

end
