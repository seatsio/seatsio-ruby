# seatsio-ruby, the official Seats.io Ruby client library

[![Build](https://github.com/seatsio/seatsio-ruby/workflows/Build/badge.svg)](https://github.com/seatsio/seatsio-ruby/actions/workflows/build.yml)
[![Gem Version](https://badge.fury.io/rb/seatsio.svg)](https://badge.fury.io/rb/seatsio)

This is the official Ruby client library for the [Seats.io V2 REST API](https://docs.seats.io/docs/api-overview), supporting Ruby 2.2.0+

## Versioning

seatsio-ruby follows semver since v23.3.0.

## Examples

### Creating a chart and an event

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key") # can be found on https://app.seats.io/workspace-settings
chart = client.charts.create
event = client.events.create chart_key: chart.key
```

### Booking objects

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
client.events.book(event.key, ["A-1", "A-2"])
```

### Releasing objects

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
client.events.release(event.key, ["A-1", "A-2"])
```

### Booking objects that have been held

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
client.events.book(event.key, ["A-1", "A-2"], hold_token: "a-hold-token")
```

### Changing object status

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
client.events.change_object_status("<EVENT KEY>", ["A-1", "A-2"], "my-custom-status")
```

### Retrieving object category and status (and other information)

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
object_infos = client.events.retrieve_object_infos key: event.key, labels: ['A-1', 'A-2']

puts object_infos['A-1'].category_key
puts object_infos['A-1'].category_label
puts object_infos['A-1'].status

puts object_infos['A-2'].category_key
puts object_infos['A-2'].category_label
puts object_infos['A-2'].status
```

### Listing all charts

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
charts = client.charts.list
charts.each do |chart|
  puts chart.key
end
```

Note: `list` returns an `Enumerable`, which under the hood calls the seats.io API to fetch charts page by page. So multiple API calls may be done underneath to fetch all charts.

### Listing charts page by page

E.g. to show charts in a paginated list on a dashboard.

Each page is Enumerable, and it has `next_page_starts_after` and `previous_page_ends_before` properties. Those properties are the chart IDs after which the next page starts or the previous page ends.

```ruby
# ... user initially opens the screen ...
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
firstPage = client.charts.list.first_page()
firstPage.each do |chart|
  puts chart.key
end
```

```ruby
# ... user clicks on 'next page' button ...
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
nextPage = client.charts.list.page_after(firstPage.next_page_starts_after)
nextPage.each do |chart|
  puts chart.key
end
```

```ruby
# ... user clicks on 'previous page' button ...
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
previousPage = client.charts.list.page_before(nextPage.previous_page_ends_before)
previousPage.each do |chart|
  puts chart.key
end
```

### Creating a workspace

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-company-admin-key") # can be found on https://app.seats.io/company-settings
client.workspaces.create name: "a workspace"
```

### Creating a chart and an event with the company admin key

```ruby
require('seatsio')
# company admin key can be found on https://app.seats.io/company-settings
# workspace public key can be found on https://app.seats.io/workspace-settings
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-company-admin-key", "my-workspace-public-key")
chart = client.charts.create
event = client.events.create chart_key: chart.key
```

# Error handling

When an API call results in a 4xx or 5xx error (e.g. when a chart could not be found), a SeatsioException is thrown.

This exception contains a message string describing what went wrong, and also two other properties:

* *errors*: a list of errors that the server returned. In most cases, this array will contain only one element, an instance of ApiError, containing an error code and a message.
* *requestId*: the identifier of the request you made. Please mention this to us when you have questions, as it will make debugging easier.


## Rate limiting - exponential backoff

This library supports [exponential backoff](https://en.wikipedia.org/wiki/Exponential_backoff).

When you send too many concurrent requests, the server returns an error `429 - Too Many Requests`. The client reacts to this by waiting for a while, and then retrying the request.
If the request still fails with an error `429`, it waits a little longer, and try again. By default this happens 5 times, before giving up (after approximately 15 seconds).

To change the maximum number of retries, create the client as follows:

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key", max_retries = 3)
```

Passing in 0 disables exponential backoff completely. In that case, the client will never retry a failed request.
