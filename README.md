[![Gem Version](https://badge.fury.io/rb/passkeys-rails.svg?cachebust=5)](https://badge.fury.io/rb/passkeys-rails)
[![Build Status](https://app.travis-ci.com/alliedcode/passkeys-rails.svg?branch=main)](https://travis-ci.org/alliedcode/passkeys-rails)
[![codecov](https://codecov.io/gh/alliedcode/passkeys-rails/branch/main/graph/badge.svg?token=UHSNJDUL21)](https://codecov.io/gh/alliedcode/passkeys-rails)

# PasskeysRails
Devise is awesome, but we don't need all that UI/UX for PassKeys.  This gem is to make
it easy to provide a back end that authenticates a mobile front end with PassKeys.

## Usage
rails passkeys-rails::install
PasskeysRails maintains an Agent model and related Passeys.  If you have a user model,
add `include PasskeysRails::Authenticatable` to your model and include the name of that
class (e.g. "User") in the authenticatable_class param when calling the register API.

### Optionally providing a "user" model during registration
PasskeysRails does not require that you supply your own model, but it's often useful to do so.  For example,
if you have a User model that you would like to have created at registration, you can supply the model name
in the finishRegistration API call.

PasskeysRails supports multiple "user" models.  Whatever model name you supply in the finishRegiration call will
be created and provided an opportunity to do any required initialization at that time.

There are two PasskeysRails configuration options related to this.

default_class and class_whitelist

#### default_class

Configure default_class in passkeys_rails.rb.  Its value will be used during registration if none
is provided in the API call.  It is "User" by default.  Since it's just a default, it can be overridden
in the API call for any other model.  If no model is to be used, change it to nil.

#### class_whitelist

Configure class_whitelist in passkeys_rails.rb.  It is nil by default.  When nil, no whitelist will be applied.
If it is non-nil, it should be an array of class names that are allowed during registration.  Supply an empty
array to prevent PasskeysRails from attempting to create anything other than its own PasskeysRails::Agent during
registration.

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
