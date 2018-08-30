# ActiveCacheModel

Simple encapsulation for using Rails.cache like ActiveRecord.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_cache_model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_cache_model

## Usage

```ruby
class Foo < ActiveCacheModel::Base
  config.handler = Rails.cache   # is default setting
  config.auto_destroy_in = 1.day # 1 day after **updated_at**
  config.enable_query = false    # `query` is UNUSED yet
  primary_key :uuid, String, defaults_to: -> { SecureRandom.uuid }
  # or `primary_key :id`, it will increase itself.

  date_time :time
    integer :status, enum: %i[ done error ], defaults_to: 0
     string :bar, presence: true, inclusion: %w[ aa bb ]
    boolean :bool
end
```

```ruby
class ReorgCacheIndices < ApplicationJob
  queue_as :default

  def perform(*args)
    YourModel.reorganize_indices
    ReorgCacheIndices.set(wait: YourModel.config.auto_destroy_in).perform_later
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/active_cache_model. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveCacheModel project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/active_cache_model/blob/master/CODE_OF_CONDUCT.md).
