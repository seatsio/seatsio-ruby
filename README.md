# seatsio-ruby, the official Seats.io Ruby client library

[![Build Status](https://travis-ci.org/seatsio/seatsio-ruby.svg?branch=master)](https://travis-ci.org/seatsio/seatsio-ruby)
[![Coverage Status](https://coveralls.io/repos/github/seatsio/seatsio-ruby/badge.svg?branch=master)](https://coveralls.io/github/seatsio/seatsio-ruby?branch=master)

This is the official Ruby client library for the [Seats.io V2 REST API](https://docs.seats.io/docs/api-overview), supporting Ruby 2.2.0+


# Versioning

seatsio-ruby only uses major version numbers: v5, v6, v7 etc. Each release - backwards compatible or not - receives a new major version number.

The reason: we want to play safe and assume that each release might break backwards compatibility.

## Examples

### Creating a chart and an event

```ruby
require('seatsio')
client = Seatsio::Client.new("my-secret-key") # can be found on https://app.seats.io/settings
chart = client.charts.create
event = client.events.create(chart.key)
```

### Booking objects

```ruby
require('seatsio')
client = Seatsio::Client.new("my-secret-key")
client.events.book(event.key, ["A-1", "A-2"])
```

### Releasing objects

```ruby
require('seatsio')
client = Seatsio::Client.new("my-secret-key")
client.events.release(event.key, ["A-1", "A-2"])
```

### Booking objects that have been held

```ruby
require('seatsio')
client = Seatsio::Client.new("my-secret-key")
client.events.book(event.key, ["A-1", "A-2"], "a-hold-token")
```

### Changing object status

```ruby
require('seatsio')
client = Seatsio::Client.new("my-secret-key")
client.events.change_object_status("<EVENT KEY>", ["A-1", "A-2"], "my-custom-status")
```

### Listing all charts

```ruby
require('seatsio')
client = Seatsio::Client.new("my-secret-key")
charts = client.charts.list # returns a Enumerable
```

### Listing the first page of charts (default page size is 20)

```ruby
require('seatsio')
client = Seatsio::Client.new("my-secret-key")
charts = client.charts.list.first_page # returns a Enumerable
```

#Error handling

When an API call results in a 4xx or 5xx error (e.g. when a chart could not be found), a SeatsioException is thrown.

This exception contains a message string describing what went wrong, and also two other properties:

* *errors*: a list of errors that the server returned. In most cases, this array will contain only one element, an instance of ApiError, containing an error code and a message.
* *requestId*: the identifier of the request you made. Please mention this to us when you have questions, as it will make debugging easier.
