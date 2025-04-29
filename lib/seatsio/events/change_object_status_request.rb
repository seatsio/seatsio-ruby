def create_change_object_status_request(type, object_or_objects, status, hold_token, order_id, event_key_or_keys, keep_extra_data, ignore_channels, channel_keys, allowed_previous_statuses, rejected_previous_statuses, resale_listing_id)
  result = {}
  result[:type] = type
  result[:objects] = normalize(object_or_objects)
  result[:type] = type
  result[:status] = status if type != Seatsio::StatusChangeType::RELEASE
  result[:holdToken] = hold_token if hold_token != nil
  result[:orderId] = order_id if order_id != nil
  if event_key_or_keys.is_a? Array
    result[:events] = event_key_or_keys
  else
    result[:events] = [event_key_or_keys]
  end
  result[:keepExtraData] = keep_extra_data if keep_extra_data != nil
  result[:ignoreChannels] = ignore_channels if ignore_channels != nil
  result[:channelKeys] = channel_keys if channel_keys != nil
  result[:allowedPreviousStatuses] = allowed_previous_statuses if allowed_previous_statuses != nil
  result[:rejectedPreviousStatuses] = rejected_previous_statuses if rejected_previous_statuses != nil
  result[:resaleListingId] = resale_listing_id if resale_listing_id != nil
  result
end

def normalize(object_or_objects)
  if object_or_objects.is_a? Array
    if object_or_objects.length == 0
      []
    end

    result = []
    object_or_objects.each do |object|
      result << object
    end
    return result

  end
  normalize([object_or_objects])
end
