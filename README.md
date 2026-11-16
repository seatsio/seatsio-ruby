# seatsio-ruby, the official Seats.io Ruby SDK

[![Build](https://github.com/seatsio/seatsio-ruby/workflows/Build/badge.svg)](https://github.com/seatsio/seatsio-ruby/actions/workflows/build.yml)
[![Gem Version](https://badge.fury.io/rb/seatsio.svg)](https://badge.fury.io/rb/seatsio)

This is the official Ruby client library for the [Seats.io V2 REST API](https://docs.seats.io/docs/api-overview), supporting Ruby 3.3 to 4.0

## Versioning

seatsio-ruby follows semver since v23.3.0.

## API reference

You can find a full API reference at https://www.rubydoc.info/gems/seatsio/

## Usage

### General instructions

To use this library, you'll need to create a `Seatsio::Client`:

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
...
```

You can find your _workspace secret key_ in the [settings section of the workspace](https://app.seats.io/workspace-settings).

The region should correspond to the region of your account:

- `Seatsio::Region.EU()`: Europe
- `Seatsio::Region.NA()`: North-America
- `Seatsio::Region.SA()`: South-America
- `Seatsio::Region.OC()`: Oceania

If you're unsure about your region, have a look at your [company settings page](https://app.seats.io/company-settings).

### Creating a chart and an event

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
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

### Listing a chart's categories

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key")
categories = [
  { 'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false },
  { 'key' => 'cat2', 'label' => 'Category 2', 'color' => '#bbbbbb', 'accessible' => true }
]
chart = client.charts.create categories: categories

category_list = client.charts.list_categories(chart.key)
category_list.each_with_index do |category, index|
  puts category.key
end
```

### Updating a category

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-company-admin-key", "my-workspace-public-key")
@seatsio.charts.update_category(chart_key: '<the chart key>', category_key: '<the category key>', label: "New label", color: "#bbbbbb", accessible: true)
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


## Idempotency

**NOTE**: Idempotency is currently in a soft launch: it is enabled per company and not yet publicly available. Contact seats.io support to have it enabled for your company.

Every `POST`, `PUT` and `DELETE` request is sent with an `Idempotency-Key` header (a v4 UUID, generated by the client). If idempotency is enabled for your company, the server executes a request with a given key only once, and replays the original response (with the header `Idempotent-Replayed: true`) when it receives the same request again. If it isn't enabled, the server ignores the key.

If the connection fails after the server executed a request but before you received the response, you don't know whether the operation succeeded. The exception contains the key, so you can retry the operation with the same key:

```ruby
begin
  client.events.create(chart_key: chart_key)
rescue Seatsio::Exception::SeatsioException => e
  # only retry when the outcome is unknown (a connection error, a timeout or a 5xx); retrying a 4xx can never succeed
  client.with_idempotency_key(e.idempotency_key).events.create(chart_key: chart_key)
end
```

The retried request must be identical to the original one, otherwise the server returns an error `422`. All requests made with the client returned by `with_idempotency_key` send the same key, so use it for one operation only. You can also supply your own key (for example `SecureRandom.uuid`); it must be a v4 UUID, otherwise `with_idempotency_key` raises an `ArgumentError`.

The key is only set on exceptions of `POST`, `PUT` and `DELETE` requests. When one of those fails for another reason than an error response from the server (e.g. a dropped connection), the original error is available as the exception's `cause`.

### Automatic retries

If the server answers `409` because an earlier request with the same key is still being processed, the client waits and retries it with the same key, like it does for `429`.

By default, the client doesn't retry requests when the connection fails. To retry `POST`, `PUT` and `DELETE` requests (with the same key) when the connection fails, enable it **only if idempotency is enabled for your company**. Otherwise, a retry could execute an operation that already succeeded a second time:

```ruby
client.retry_non_idempotent_requests = true
```

The setting applies to the client and to every client returned by its `with_idempotency_key`, whether they were created before or after it was set.

Retries after a connection failure wait with some randomness (jitter), so that many clients don't retry at the same moment. A request that timed out while waiting for the response (10 seconds) is retried only once, to avoid adding load to a server that is already slow. Every attempt can take up to 10 seconds, so in the worst case (e.g. when the server can't be reached) a request only fails after `max_retries + 1` attempts plus the waits in between: about 70 seconds with the default `max_retries` of 5. Lower `max_retries` to shorten that.

## Rate limiting - exponential backoff

This library supports [exponential backoff](https://en.wikipedia.org/wiki/Exponential_backoff).

When you send too many concurrent requests, the server returns an error `429 - Too Many Requests`. The client reacts to this by waiting for a while, and then retrying the request.
If the request still fails with an error `429`, it waits a little longer, and try again. By default this happens 5 times, before giving up (after approximately 15 seconds).

We throw a `RateLimitExceededException` (which is a subclass of `SeatsioException`) when exponential backoff eventually fails.

To change the maximum number of retries, create the client as follows:

```ruby
require('seatsio')
client = Seatsio::Client.new(Seatsio::Region.EU(), "my-workspace-secret-key", max_retries = 3)
```

Passing in 0 disables exponential backoff completely. In that case, the client will never retry a failed request.
