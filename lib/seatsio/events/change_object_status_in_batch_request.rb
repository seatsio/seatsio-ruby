def create_change_object_status_in_batch_request(event_key, object_or_objects, status, hold_token = nil , order_id = nil, keep_extra_data = nil, ignore_channels = nil, channel_keys = nil)
  result = create_change_object_status_request(object_or_objects, status, hold_token, order_id, '', keep_extra_data, ignore_channels, channel_keys)
  result.delete(:events)
  result[:event] = event_key
  result
end
