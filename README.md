# seatsio-ruby, the official Seats.io Ruby client library

[![Build Status](https://travis-ci.org/seatsio/seatsio-ruby.svg?branch=master)](https://travis-ci.org/seatsio/seatsio-ruby)

This is the official Ruby client library for the [Seats.io V2 REST API](https://docs.seats.io/docs/api-overview), supporting Ruby 2.2.0+

## Versioning

seatsio-ruby follows semver since v23.3.0.

## Examples

### Creating a chart and an event

```ruby
require('seatsio')
client = Seatsio::Client.new("my-workspace-secret-key") # can be found on https://app.seats.io/workspace-settings
chart = client.charts.create
event = client.events.create key: chart.key
```

### Booking objects

```ruby
require('seatsio')
client = Seatsio::Client.new("my-workspace-secret-key")
client.events.book(event.key, ["A-1", "A-2"])
```

### Releasing objects

```ruby
require('seatsio')
client = Seatsio::Client.new("my-workspace-secret-key")
client.events.release(event.key, ["A-1", "A-2"])
```

### Booking objects that have been held

```ruby
require('seatsio')
client = Seatsio::Client.new("my-workspace-secret-key")
client.events.book(event.key, ["A-1", "A-2"], "a-hold-token")
```

### Changing object status

```ruby
require('seatsio')
client = Seatsio::Client.new("my-workspace-secret-key")
client.events.change_object_status("<EVENT KEY>", ["A-1", "A-2"], "my-custom-status")
```

### Listing all charts

```ruby
require('seatsio')
client = Seatsio::Client.new("my-workspace-secret-key")
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

firstPage = client.charts.list.first_page()
firstPage.each do |chart|
  puts chart.key
end
```

```ruby
# ... user clicks on 'next page' button ...

nextPage = client.charts.list.page_after(firstPage.next_page_starts_after)
nextPage.each do |chart|
  puts chart.key
end
```

```ruby
# ... user clicks on 'previous page' button ...

previousPage = client.charts.list.page_before(nextPage.previous_page_ends_before)
previousPage.each do |chart|
  puts chart.key
end
```

### Creating a workspace

```ruby
require('seatsio')
client = Seatsio::Client.new("my-company-admin-key")
client.workspaces.create name: "a workspace"
```

# Error handling

When an API call results in a 4xx or 5xx error (e.g. when a chart could not be found), a SeatsioException is thrown.

This exception contains a message string describing what went wrong, and also two other properties:

* *errors*: a list of errors that the server returned. In most cases, this array will contain only one element, an instance of ApiError, containing an error code and a message.
* *requestId*: the identifier of the request you made. Please mention this to us when you have questions, as it will make debugging easier.
