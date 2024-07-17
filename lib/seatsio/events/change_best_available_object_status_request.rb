def create_change_best_available_object_status_request(number, status, categories, zone, extra_data, ticket_types, hold_token, order_id, keep_extra_data, ignore_channels, channel_keys, try_to_prevent_orphan_seats)
  result = {}
  best_available = {'number': number}
  best_available[:categories] = categories if categories != nil
  best_available[:zone] = zone if zone != nil
  best_available[:extraData] = extra_data if extra_data != nil
  best_available[:ticketTypes] = ticket_types if ticket_types != nil
  best_available[:tryToPreventOrphanSeats] = try_to_prevent_orphan_seats if try_to_prevent_orphan_seats != nil
  result[:status] = status
  result[:bestAvailable] = best_available
  result[:holdToken] = hold_token if hold_token != nil
  result[:orderId] = order_id if order_id != nil
  result[:keepExtraData] = keep_extra_data if keep_extra_data != nil
  result[:ignoreChannels] = ignore_channels if ignore_channels != nil
  result[:channelKeys] = channel_keys if channel_keys != nil
  result
end
