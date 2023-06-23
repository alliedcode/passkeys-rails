# MobilePass
Short description and motivation.

## Usage
rails mobile_pass::install
MobilePass maintains an Agent model and related Passeys.  If you have a user model, add `include MobilePass::Authenticatable` to your model and include the name of that class (e.g. "User") in the authenticatable_class param when calling the passkeys/register API.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "mobile_pass"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install mobile_pass
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
