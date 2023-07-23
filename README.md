# PasskeysRails
Short description and motivation.

## Usage
rails passkeys-rails::install
PasskeysRails maintains an Agent model and related Passeys.  If you have a user model, add `include PasskeysRails::Authenticatable` to your model and include the name of that class (e.g. "User") in the authenticatable_class param when calling the register API.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "passkeys_rails"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install passkeys_rails
```

## Coverage
[![codecov](https://codecov.io/gh/alliedcode/passkeys-rails/branch/main/graph/badge.svg?token=UHSNJDUL21)](https://codecov.io/gh/alliedcode/passkeys-rails)

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
