[![Gem Version](https://badge.fury.io/rb/passkeys-rails.svg?cachebust=5)](https://badge.fury.io/rb/passkeys-rails)
[![Build Status](https://app.travis-ci.com/alliedcode/passkeys-rails.svg?branch=main)](https://travis-ci.org/alliedcode/passkeys-rails)
[![codecov](https://codecov.io/gh/alliedcode/passkeys-rails/branch/main/graph/badge.svg?token=UHSNJDUL21)](https://codecov.io/gh/alliedcode/passkeys-rails)

# PasskeysRails

Devise is awesome, but we don't need all that UI/UX for PassKeys.

The purpose of this gem is to make it easy to provide a rails back end API that supports PassKey authentication.  It uses the [`webauthn`](https://github.com/w3c/webauthn) gem to do the cryptographic work and presents a simple API interface for passkey registration and authentication.

The target use case for this gem is a mobile application that uses a rails based API service to manage resources.  The goal is to make it simple to register and authenticate users using passkeys from mobile applications in a rails API service.

## Usage

    rails g passkeys_rails::install

**PasskeysRails** maintains an `Agent` model and related `Passeys`.  If you have a user model, add `include PasskeysRails::Authenticatable` to your model and include the name of that class (e.g. `"User"`) in the `authenticatable_class` param when calling the register API or set the `PasskeysRails.default_class` to the name of that class.

### Optionally providing a **"user"** model during registration

**PasskeysRails** does not require that you supply your own model, but it's often useful to do so.  For example, if you have a User model that you would like to have created at registration, you can supply the model name in the `finishRegistration` API call.

**PasskeysRails** supports multiple `"user"` models.  Whatever model name you supply will be created during a successful the `finishRegiration` API call. When created, it will be provided an opportunity to do any initialization at that time.

There are two **PasskeysRails** configuration options related to this: `default_class` and `class_whitelist` - see below.

#### `default_class`

Configure `default_class` in `passkeys_rails.rb`.  Its value will be used during registration if none is provided in the API call.  The default value is `"User"`.  Since the `default_class` is just a default, it can be overridden in the `finishRegiration` API call to use a different model.  If no model is to be used by default, set it to nil.

#### `class_whitelist`

Configure `class_whitelist` in `passkeys_rails.rb`.  The default value is `nil`.  When `nil`, no whitelist will be applied. If it is non-nil, it should be an array of class names that are allowed during registration.  Supply an empty array to prevent **PasskeysRails** from attempting to create anything other than its own `PasskeysRails::Agent` during registration.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "passkeys_rails"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install passkeys_rails
```

Depending on your application's configuration some manual setup may be required:

  1. Add a before_action to all controllers that require authentication to use.

     For example:

        `before_action :authenticate_passkey!, except: [:index]`

  2. Optionally `include PasskeysRails::Authenticatable` in the model(s) you are using for authentication.  For example, your `User` model.

  3. See the reference mobile applications for how to use **passkeys-rails** for passkey authentication.

## Contributing

Contact me if you'd like to contribute time, energy, etc. to this project.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
