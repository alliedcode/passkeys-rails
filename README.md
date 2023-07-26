[![Gem Version](https://badge.fury.io/rb/passkeys-rails.svg?cachebust=7)](https://badge.fury.io/rb/passkeys-rails)
[![Build Status](https://app.travis-ci.com/alliedcode/passkeys-rails.svg?branch=main)](https://travis-ci.org/alliedcode/passkeys-rails)
[![codecov](https://codecov.io/gh/alliedcode/passkeys-rails/branch/main/graph/badge.svg?token=UHSNJDUL21)](https://codecov.io/gh/alliedcode/passkeys-rails)

# PasskeysRails

Devise is awesome, but we don't need all that UI/UX for PassKeys.

The purpose of this gem is to make it easy to provide a rails back end API that supports PassKey authentication.  It uses the [`webauthn`](https://github.com/w3c/webauthn) gem to do the cryptographic work and presents a simple API interface for passkey registration and authentication.

The target use case for this gem is a mobile application that uses a rails based API service to manage resources.  The goal is to make it simple to register and authenticate users using passkeys from mobile applications in a rails API service.


## Usage

**PasskeysRails** maintains an `Agent` model and related `Passkeys`.  If you have a user model, add `include PasskeysRails::Authenticatable` to your model and include the name of that class (e.g. `"User"`) in the `authenticatable_class` param when calling the register API or set the `PasskeysRails.default_class` to the name of that class.

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

Finally, execute:

```bash
$ rails generate passkeys_rails:install
```

This will add the `passkeys_rails.rb` configuration file, passkeys routes, and a couple of database migrations to your project.

### Adding to an standard rails project

1. Add `before_action :authenticate_passkey!`

 To prevent access to controller actions, add `before_action :authenticate_passkey!`.  If an action is attempted without an authenticated entity, an error will be rendered in JSON with an :unauthorized result code.

1. Use `current_agent` and `current_agent.authenticatable`

 To access the currently authenticated entity, use `current_agent`.  If you associated the registration of the agent with one of your own models, use `current_agent.authenticatable`.  For example, if you associated the `User` class with the registration, `current_agent.authenticatable` will be a User object.

1. Add `include PasskeysRails::Authenticatable` to model class(es)

 If you have one or more classes that you want to use with authentication - e.g. a User class and an AdminUser class - add `include PasskeysRails::Authenticatable` to each of those classes.  That adds a `registered?` method that you can call on your model to determine if they are registerd with your service, and a `registering_with(params)` method that you can override to initialize attributes of your model when it is created during registration. `params` is a hash with params passed to the API when registering.  When called, your object has been built, but not yet saved.  Upon return, **PasskeysRails** will attempt to save your object before finishing registration.  If it is not valid, the registration will fail as well, returning the error error details to the caller.

### Adding to a Grape API rails project

1. Call `PasskeysRails.authenticate(request)` to authenticate the request.

 Call `PasskeysRails.authenticate(request)` to get an object back that responds to `.success?` and `.failure?` as well as `.agent`, `.code`, and `.message`.

 Alternatively, call `PasskeysRails.authenticate!(request)` from a helper in your base class.  It will raise a `PasskeysRails.Error` exception if the caller isn't authenticated.  You can catch the exception and render an appropriate error.  The exception contains the error code and message.

1. Consider adding the following helpers to your base API class:

```ruby
  helpers do
    # Authenticate the request and cache the result
    def passkey
      @passkey ||= PasskeysRails.authenticate(request)
    end

    # Raise an exception if the request is not authentic
    def authenticate_passkey!
      error!({ code: passkey.code, message: passkey.message }, :unauthorized) if passkey.failure?
    end

    # Return the Passkeys::Agent if authentic, else return nil
    def current_agent
      passkey.agent
    end

    # If you have set authenticatable to be a User, you can use this to access the user from Grape endpoint methods
    def current_user
      user = current_agent&.authenticatable
      user.is_a?(User) ? user : nil # sanity check to be sure authenticatable is a User
    end
  end
```

 To prevent access to various endpoints, add `before_action :authenticate_passkey!` or call `authenticate_passkey!` from any method that requires authentication.  If an action is attempted without an authenticated entity, an error will be rendered in JSON with an :unauthorized result code.

1. Use `current_agent` and `current_agent.authenticatable`

 To access the currently authenticated entity, use `current_agent`.  If you associated the registration of the agent with one of your own models, use `current_agent.authenticatable`.  For example, if you associated the `User` class with the registration, `current_agent.authenticatable` will be a User object.

### Authentication Failure

1. In the event of authentication failure, PasskeysRails returns an error code and message.

1. In a standard rails controller, the error code and message are rendered in JSON if `before_action :authenticate_passkey!` fails.

1. In Grape, the error code and message are available in the result of the `PasskeysRails.authenticate(request)` method.

1. From standard rails controllers, you can also access `passkey_authentication_result` to get the code and message.

1. For `PasskeysRails.authenticate(request)` and `passkey_authentication_result`, the result is an object that respods to `.success?` and `.failure?`.
 - When `.success?` is true (`.failure?` is false), the resources is authentic and it also responds to `.agent`, returning a PasskeysRails::Agent
 - When `.success?` is false (`.failure?` is true), it responds to `.code` and `.message` to expose the error details.
 - When `.code` is `:missing_token`, `.message` is **X-Auth header is required**, which means the caller didn't supply the auth header.
 - When `.code` is `:invalid_token`, `.message` is **Invalid token - no agent exists with agent_id**, which means that the auth data is not valid.
 - When `.code` is `:expired_token`, `.message` is **The token has expired**, which means that the token is valid, but expired, thuis it's not considered authentic.
 - When `.code` is `:token_error`, `.message` is a description of the error.  This is a catch-all in the event we are unable to decode the token.

 In the future, the intention is to have the `.code` value stay consistent even if the `.message` changes.  This also allows you to localize the messages as need using the code.

### Test Helpers

PasskeysRails includes some test helpers for integration tests.  In order to use them, you need to include the module in your test cases/specs.

### Integration tests

Integration test helpers are available by including the `PasskeysRails::IntegrationHelpers` module.

```ruby
class PostTests < ActionDispatch::IntegrationTest
  include PasskeysRails::Test::IntegrationHelpers
end
```
Now you can use the following `logged_in_headers` method in your integration tests.`

```ruby
  test 'authenticated users can see posts' do
    user = User.create
    get '/posts', headers: logged_in_headers('username-123', user)
    assert_response :success
  end
```

RSpec can include the `IntegrationHelpers` module in their `:feature` and `:request` specs.

```ruby
RSpec.configure do |config|
  config.include PasskeysRails::Test::IntegrationHelpers, type: :feature
  config.include PasskeysRails::Test::IntegrationHelpers, type: :request
end
```

```ruby
RSpec.describe 'Posts', type: :request do
  let(:user) { User.create }
  it "allows authenticated users to see posts" do
    get '/posts', headers: logged_in_headers('username-123', user)
    expect(response).to be_success
  end
end
```

### Mobile Application Integration

**TODO**: Describe the APIs and point to the soon-to-be-created reference mobile applications for how to use **passkeys-rails** for passkey authentication.

## Contributing

Contact me if you'd like to contribute time, energy, etc. to this project.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
