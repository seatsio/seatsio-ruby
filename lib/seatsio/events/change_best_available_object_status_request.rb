def create_change_best_available_object_status_request(number, status, categories = nil, extra_data = nil,  hold_token = nil, order_id = nil)
  result = {}
  best_available = {'number': number}
  best_available[:categories] = categories if categories != nil
  best_available[:extraData] = extra_data if extra_data != nil
  result[:status] = status
  result[:bestAvailable] = best_available
  result[:holdToken] = hold_token if hold_token != nil
  result[:orderId] = order_id if order_id != nil
  result
end
