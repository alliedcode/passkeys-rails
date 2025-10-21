# PasskeysRails - easy to integrate back end for implementing mobile passkeys

[![Gem Version](https://badge.fury.io/rb/passkeys-rails.svg?cachebust=0.2.1)](https://badge.fury.io/rb/passkeys-rails)
[![Build Status](https://app.travis-ci.com/alliedcode/passkeys-rails.svg?branch=main)](https://travis-ci.org/alliedcode/passkeys-rails)
[![codecov](https://codecov.io/gh/alliedcode/passkeys-rails/branch/main/graph/badge.svg?token=UHSNJDUL21)](https://codecov.io/gh/alliedcode/passkeys-rails)

<p align="center" >
Created by <b>Troy Anderson, Allied Code</b> - <a href="https://alliedcode.com">alliedcode.com</a>
</p>

PasskeysRails is a gem you can add to a Rails app to enable passskey registration and authorization from mobile front ends.  PasskeysRails leverages webauthn for the cryptographic work, and presents a simple API interface for passkey registration, authentication, and testing.

The purpose of this gem is to make it easy to provide a rails back end API that supports PassKey authentication.  It uses the [`webauthn`](https://github.com/w3c/webauthn) gem to do the cryptographic work and presents a simple API interface for passkey registration and authentication.

The target use case for this gem is a mobile application that uses a rails based API service to manage resources.  The goal is to make it simple to register and authenticate users using passkeys from mobile applications in a rails API service.

What about [devise](https://github.com/heartcombo/devise)?  Devise is awesome, but we don't need all that UI/UX for PassKeys, especially for an API back end.

## Documentation
* [Usage](#usage)
* [Installation](#installation)
* [Rails Integration - Standard](#rails-Integration-standard)
* [Rails Integration - Grape](#rails-Integration-grape)
* [Notifications](#notifications)
* [Failure Codes](#failure-codes)
* [Testing](#testing)
* [Mobile App Integration](#mobile-application-integration)
* [Reference/Example Mobile Applications](#referenceexample-mobile-applications)

## Usage

**PasskeysRails** maintains a `PasskeysRails::Agent` model and related `PasskeysRails::Passkeys`.  In rails apps that maintain their own "user" model, add `include PasskeysRails::Authenticatable` to that model and include the name of that class (e.g. `"User"`) in the `authenticatable_class` param when calling the register API or set the `PasskeysRails.default_class` to the name of that class.

In mobile apps, leverage the platform specific Passkeys APIs for ***registration*** and ***authentication***, and call the **PasskeysRails** API endpoints to complete the ceremony.  **PasskeysRails** provides endpoints to support ***registration***, ***authentication***, ***token refresh***, and ***debugging***.

### Optionally providing a **"user"** model during registration

**PasskeysRails** does not require any application specific models, but it's often useful to have one.  For example, a User model can be created at registration.  **PasskeysRails** provides two mechanisms to support this.  Either provide the name of the model in the `authenticatable_class` param when calling the `finishRegistration` endpoint, or set a `default_class` in `config/initializers/passkeys_rails.rb`.

**PasskeysRails** supports multiple different application specific models.  Whatever model name supplied when calling the `finishRegistration` endpoint will be created during a successful the `finishRegistration` process. When created, it will be provided an opportunity to do any initialization at that time.

There are two **PasskeysRails** configuration options related to this: `default_class` and `class_whitelist`:

#### `default_class`

Configure `default_class` in `config/initializers/passkeys_rails.rb`.  Its value will be used during registration if none is provided in the API call.  The default value is `"User"`.  Since the `default_class` is just a default, it can be overridden in the `finishRegiration` API call to use a different model.  If no model is to be used by default, set it to nil.

#### `class_whitelist`

Configure `class_whitelist` in `config/initializers/passkeys_rails.rb`.  The default value is `nil`.  When `nil`, no whitelist will be applied. If it is non-nil, it should be an array of class names that are allowed during registration.  Supply an empty array to prevent **PasskeysRails** from attempting to create anything other than its own `PasskeysRails::Agent` during registration.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "passkeys-rails"
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

This will add the `config/initializers/passkeys_rails.rb` configuration file, passkeys routes, and a couple of database migrations to your project.


<a id="rails-Integration-standard"></a>
## Rails Integration <p><small>Adding to a standard rails project</small></p>

- ### Add `before_action :authenticate_passkey!`

To prevent access to controller actions, add `before_action :authenticate_passkey!`.  If an action is attempted without an authenticated entity, an error will be rendered in JSON with an :unauthorized result code.

- ### Use `current_agent` and `current_agent.authenticatable`

To access the currently authenticated entity, use `current_agent`.  If you associated the registration of the agent with one of your own models, use `current_agent.authenticatable`.  For example, if you associated the `User` class with the registration, `current_agent.authenticatable` will be a User object.

- ### Add `include PasskeysRails::Authenticatable` to model class(es)

 If you have one or more classes that you want to use with authentication - e.g. a User class and an AdminUser class - add `include PasskeysRails::Authenticatable` to each of those classes.  That adds a `registered?` method that you can call on your model to determine if they are registerd with your service, and a `registering_with(params)` method that you can override to initialize attributes of your model when it is created during registration. `params` is a hash with params passed to the API when registering.  When called, your object has been built, but not yet saved.  Upon return, **PasskeysRails** will attempt to save your object before finishing registration.  If it is not valid, the registration will fail as well, returning the error error details to the caller.

<a id="rails-Integration-grape"></a>
## Rails Integration - <p><small>Adding to a Grape API rails project</small></p>

- ### Call `PasskeysRails.authenticate(request)` to authenticate the request.

 Call `PasskeysRails.authenticate(request)` to get an object back that responds to `.success?` and `.failure?` as well as `.agent`, `.code`, and `.message`.

 Alternatively, call `PasskeysRails.authenticate!(request)` from a helper in your base class.  It will raise a `PasskeysRails.Error` exception if the caller isn't authenticated.  You can catch the exception and render an appropriate error.  The exception contains the error code and message.

- ### Consider adding the following helpers to your base API class:

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

- ### Use `current_agent` and `current_agent.authenticatable`

 To access the currently authenticated entity, use `current_agent`.  If you associated the registration of the agent with one of your own models, use `current_agent.authenticatable`.  For example, if you associated the `User` class with the registration, `current_agent.authenticatable` will be a User object.

## Notifications

Certain actions trigger notifications that can be subscribed.  See `subscribe` in `config/initializers/passkeys_rails.rb`.

These are completely optional.  **PasskeysRails** will manage all the credentials and keys without these being implemented.  They are useful for taking application specific actions like logging based on the authentication related events.

### Events

- `:did_register ` - a new agent has registered

- `:did_authenticate` - an agent has been authenticated

- `:did_refresh` - an agent's auth token has been refreshed

A convenient place to set these up in is in `config/initializers/passkeys_rails.rb`

```ruby
PasskeysRails.config do |c|
  c.subscribe(:did_register) do |event, agent, request|
    # do something with the agent and/or request
  end

  c.subscribe(:did_authenticate) do |event, agent, request|
    # do something with the agent and/or request
  end
end
```

Subscriptions can also be done elsewhere as subscribe is a PasskeysRails class method.

```ruby
PasskeysRails.subscribe(:did_register) do |event, agent, request|
  # do something with the agent and/or request
end
```

## Failure Codes

1. In the event of authentication failure, **PasskeysRails** API endpoints render an error code and message.

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

 In the future, the intention is to have the `.code` value stay consistent even if the `.message` changes.  This also allows you to localize the messages as needed using the code.

## Testing

PasskeysRails includes some test helpers for integration tests.  In order to use them, you need to include the module in your test cases/specs.

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

## Mobile Application Integration

### Prerequisites

For iOS, you need to associate your app with your server.  This amounts to setting up a special file on your server that defines the association.  See [setup your apple-app-site-association](#Ensure-`.well-known/apple-app-site-association`-is-in-place)


### Mobile API Endpoints

There are 3 groups of API endpoints that your mobile application might consume.

1. Unauthenticated (public) endpoints
1. Authenticated (private) endpoints
1. Passkey endpoints (for supporting authentication)

**Unauthenticated endpoints** can be consumed without any authentication.

**Authenticated endpoints** are protected by `authenticate_passkey!` or `PasskeysRails.authenticate!(request)`.  Those methods check for and validate the `X-Auth` header, which must be set to the auth token returned in the `AuthResponse`, described below.

**Passkey endpoints** are supplied by this gem and allow you to register a user, authenticate (login) a user, and refresh the token.  This section describes these endpoints.

This gem supports the Passkey endpoints.

### Passkey Endpoints

* [POST /passkeys/challenge](post-passkeys-challenge)
* [POST /passkeys/register](post-passkeys-register)
* [POST /passkeys/authenticate](post-passkeys-authenticate)
* [POST /passkeys/refresh](post-passkeys-refresh)
* [POST /passkeys/debug_register](post-passkeys-debug-register)
* [POST /passkeys/debug_login](post-passkeys-debug-login)

All Passkey endpoints accept and respond with JSON.

On **success**, they will respond with a 200 or 201 response code and relevant JSON.

On **error**, they will respond with a status code of `422` (Unprocessable Entity) and a JSON `ErrorResponse` structure:

```JSON
{
  "error": {
    "context": "authentication",
    "code": "Specific text code",
    "message": "Some human readable message"
  }
}
```

Some endpoints return an `AuthResponse`, which has this JSON structure:

```JSON
{
    "username": String,   # the username used during registration
    "auth_token": String  # an expiring token to use to authenticate with the back end (X-Auth header)
}
```

### POST /passkeys/challenge

Submit this to begin registration or authentication.

#### Registration (register)

To begin registration of a new credential, supply a `{ "username": "unique username" }`.
If all goes well, the JSON response will be the `options_for_create` from webauthn.
If the username is already in use, or anything else goes wrong, an error with code `validation_errors` will be returned.

After receiving a successful response, follow up with a POST to `/passkeys/register`, below.

#### Authentication (login)
To begin authenticating an existing credential, omit the `username`.  The JSON response will be the `options_for_get` from webauthn.

After receiving a successful response, follow up with a POST to `/passkeys/authenticate`, below.

### POST /passkeys/register

After calling the `challenge` endpoint with a `username`, and handling its response, finish registering by calling this endpoint.

Supply the following JSON structure:

```JSON
# POST body
{
  # NOTE: credential will likely come directly from the PassKeys class/library on the platform
  "credential": {
    "id": String,
    "rawId": String,
    "type": String,
    "response": {
      "attestationObject": String,
      "clientDataJSON": String
    }
  },
  # authenticatable is optional and is informas PasskeysRails how to build your "user" model
  "authenticatable": { # optional
    "class": "User", # whatever class to which you want this credential to apply (as described earlier)
    "params": { }    # Any params you want passed as a hash to the registering_with method on that class
  }
}
```

On **success**, the response is an `AuthResponse`.

Possible **failure codes** (using the `ErrorResponse` structure) are:

- `webauthn_error` - something is wrong with the credential
- `error` - something else went wrong during credentail validation - see the `message` in the `ErrorResponse`
- `passkey_error` - unable to persist the passkey
- `invalid_authenticatable_class` - the supplied authenticatable class can't be created/found (check spelling & capitalization)
- `invalid_class_whitelist` - the whitelist in the passkeys_rails.rb configuration is invalid - be sure it's nil or an array
- `invalid_authenticatable_class` - the supplied authenticatable class is not allowed - maybe it's not in the whitelist
- `record_invalid` - the object of the supplied authenticatable class cannot be saved due to validation errors
- `agent_not_found` - the agent referenced in the credential cannot be found in the database

### POST /passkeys/authenticate

After calling the `challenge` endpoint without a `username`, and handling its response, finish authenticating by calling this endpoint.

Supply the following JSON structure:

```JSON
# POST body
{
  # NOTE: all of this will likely come directly from the PassKeys class/library on the platform
  "id": String,                   # Base64 encoded assertion.credentialID
  "rawId": String,                # Base64 encoded assertion.credentialID
  "type": "public-key",
  "response": {
    "authenticatorData": String,  # Base64 encoded assertion.rawAuthenticatorData
    "clientDataJSON": String,     # Base64 encoded assertion.rawClientDataJSON
    "signature": String,          # Base64 encoded signature
    "userHandle":String           # Base64 encoded assertion.userID
  }
}
```
On **success**, the response is an `AuthResponse`.

Possible **failure codes** (using the `ErrorResponse` structure) are:

- `webauthn_error` - something is wrong with the credential
- `passkey_not_found` - the passkey referenced in the credential cannot be found in the database

### POST /passkeys/refresh

The token will expire after some time (configurable in `config/initializers/passkeys_rails.rb`).  Before that happens, refresh it using this API.  Once it expires, to get a new token, use the `/authentication` API.

Supply the following JSON structure:

```JSON
# POST body
{
  token: String
}
```

On **success**, the response is an `AuthResponse` with a new, refreshed token.

Possible **failure codes** (using the `ErrorResponse` structure) are:

- `invalid_token` - the token data is invalid
- `expired_token` - the token is expired
- `token_error` - some other error ocurred when decoding the token

### POST /passkeys/debug_register

As it may not be possible to acess Passkey functionality in mobile simulators, this endpoint may be called to register a username while bypassing the normal challenge/response sequence.

This endpoint only responds if `DEBUG_LOGIN_REGEX` is set in the server environment.  It is **very insecure to set this variable in a production environment** as it bypasses all Passkey checks.  It is only intended to be used during mobile application development.

To use this endpoint:

1. Set `DEBUG_LOGIN_REGEX` to a regex that matches any username you want to use during development - for example `^test(-\d+)?$` will match `test`, `test-1`, `test-123`, etc.

1. In the mobile application, call this endpoint in stead of the `/passkeys/challenge` and `/passkeys/register`.  The response is identicial to that of `/passkeys/register`.

1. Use the response as if it was from `/passkeys/register`.

If you supply a username that doesn't match the `DEBUG_LOGIN_REGEX`, the endpoint will respond with an error.

Supply the following JSON structure:

```JSON
# POST body
{
  "username": String
}
```
On **success**, the response is an `AuthResponse`.

Possible **failure codes** (using the `ErrorResponse` structure) are:

- `not_allowed` - Invalid username (the username doesn't match the regex)
- `invalid_authenticatable_class` - the supplied authenticatable class can't be created/found (check spelling & capitalization)
- `invalid_class_whitelist` - the whitelist in the passkeys_rails.rb configuration is invalid - be sure it's nil or an array
- `invalid_authenticatable_class` - the supplied authenticatable class is not allowed - maybe it's not in the whitelist
- `record_invalid` - the object of the supplied authenticatable class cannot be saved due to validation errors

### POST /passkeys/debug_login

As it may not be possible to acess Passkey functionality in mobile simulators, this endpoint may be called to login (authenticate) a username while bypassing the normal challenge/response sequence.

This endpoint only responds if `DEBUG_LOGIN_REGEX` is set in the server environment.  It is **very insecure to set this variable in a production environment** as it bypasses all Passkey checks.  It is only intended to be used during mobile application development.

To use this endpoint:

1. Manually create one or more PasskeysRails::Agent records in the database.  A unique username is required for each.

1. Set `DEBUG_LOGIN_REGEX` to a regex that matches any username you want to use during development - for example `^test(-\d+)?$` will match `test`, `test-1`, `test-123`, etc.

1. In the mobile application, call this endpoint in stead of the `/passkeys/challenge` and `/passkeys/authenticate`.  The response is identicial to that of `/passkeys/authenticate`.

1. Use the response as if it was from `/passkeys/authenticate`.

If you supply a username that doesn't match the `DEBUG_LOGIN_REGEX`, the endpoint will respond with an error.

Supply the following JSON structure:

```JSON
# POST body
{
  "username": String
}
```
On **success**, the response is an `AuthResponse`.

Possible **failure codes** (using the `ErrorResponse` structure) are:

- `not_allowed` - Invalid username (the username doesn't match the regex)
- `agent_not_found` - No agent found with that username

## Reference/Example Mobile Applications

There is a sample iOS app that integrates with **passkeys-rails** based server implementations.  It's a great place to get a quick start on implementing passkyes in your iOS, iPadOS or MacOS apps.

Check out the [PasskeysRailsDemo](https://github.com/alliedcode/PasskeysRailsDemo) app.

## Contributing

### Contribution Guidelines

Thank you for considering contributing to PasskeysRails! We welcome your help to improve and enhance this project. Whether it's a bug fix, documentation update, or a new feature, your contributions are valuable to the community.

To ensure a smooth collaboration, please follow the [Contribution Guidelines](https://github.com/alliedcode/passkeys-rails/blob/main/CONTRIBUTION_GUIDELINES.md) when submitting your contributions.

### Code of Conduct

Please note that this project follows the [Code of Conduct](https://github.com/alliedcode/passkeys-rails/blob/main/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. If you encounter any behavior that violates the code, please report it to the project maintainers.

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/alliedcode/passkeys-rails/blob/main/MIT-LICENSE).
