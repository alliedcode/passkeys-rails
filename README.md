[![Gem Version](https://badge.fury.io/rb/passkeys-rails.svg)](https://badge.fury.io/rb/passkeys-rails)
[![Build Status](https://app.travis-ci.com/alliedcode/passkeys-rails.svg?branch=main)](https://travis-ci.org/alliedcode/passkeys-rails)
[![codecov](https://codecov.io/gh/alliedcode/passkeys-rails/branch/main/graph/badge.svg?token=UHSNJDUL21)](https://codecov.io/gh/alliedcode/passkeys-rails)

# PasskeysRails
Devise is awesome, but we don't need all that UI/UX for PassKeys.  This gem is to make it easy to provide a back end that authenticates a mobile front end with PassKeys.

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

Depending on your application's configuration some manual setup may be required:

  1. Add a before_action to all controllers that require authentication to use.

     For example:

        before_action :authenticate_passkey!, except: [:index]

  2. Optionally include PasskeysRails::Authenticatable to the model(s) you are using as
     your user model(s).  For example, the User model.

  3. See the reference mobile applications for how to use passkeys-rails for passkey
     authentication.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
