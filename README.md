# Eyevision

This gem is a client to EyeEm's Vision API. It provides functionality to analyze an imageand retrieve tags, captions and an aesthetic score.

The client handles request authentication and token refreshes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eyevision'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eyevision

## Usage

Usage is fairly simple. You initialize the client with your API keys and then pass images by file, url or binary input:

```ruby
require 'eyevision'

c = Eyevision::Client.new('CLIENT ID', 'CLIENT SECRET')

c.analyze(url: "https://cdn.eyeem.com/thumb/fa153872f1fb87d2c49f03da2e605cbdc343230d-1479466499934/1200/1200")
c.analyze(file: "image.jpg")
c.analyze(image: "binary")
```

By default it will retrieve tags, captions and aesthetic score but you can also request other combinations:

```ruby
c.analyze(image: "binary", features: ["TAGS", "AESTHETIC_SCORE"])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tmacedo/eyevision.

