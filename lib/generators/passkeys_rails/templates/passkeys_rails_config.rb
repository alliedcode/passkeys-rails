require 'passkeys-rails'

PasskeysRails.config do |c|
  # Secret used to encode the auth token.
  # Changing this value will invalidate all tokens that have been fetched
  # through the API.
  # Default is the application's `secret_key_base`.  You can change it below
  # and use your own secret key.
  #
  # c.auth_token_secret = '<%= SecureRandom.hex(64) %>'

  # Algorithm used to generate the auth token.
  # Changing this value will invalidate all tokens that have been fetched
  # through the API.
  # Default is HS256
  #
  # c.auth_token_algorithm = "HS256"

  # How long the auth token is valid before requiring a refresh or new login.
  # Set it to 0 for no expiration (not recommended in production).
  # Default is 30 days
  #
  # c.auth_token_expires_in = 30.days

  # Model to use when creating or authenticating a passkey.
  # This can be overridden when calling the API, but if no
  # value is supplied when calling the API, this value is used.
  #
  # If nil, there is no default, and if none is supplied when
  # calling the API, no resource is created other than
  # a PaskeysRails::Agent that is used to track the passkey.
  #
  # This library doesn't assume that there will only be one
  # model, but it is a common use case, so setting the
  # default_class simplifies the use of the API in that case.
  #
  # c.default_class = "User"

  # By providing a class_whitelist, the API will require that
  # any supplied class is in the whitelist.  If it is not, the
  # auth API will return an error.  This prevents a caller from
  # attempting to create an unintended records on registration.
  # If nil, any model will be allowed.
  # This should be an array of symbols or strings,
  # for example: %w[User AdminUser]
  #
  # c.class_whitelist = nil

  # To subscribe to various events in PasskeysRails, use the subscribe method.
  # It can be called multiple times to subscribe to more than one event.
  #
  # Valid events:
  #   :did_register
  #   :did_authenticate
  #   :did_refresh
  #
  # Each event will include the event name, current agent and http request.
  #
  # For example:
  # c.subscribe(:did_register) do |event, agent, request|
  #   puts("#{event} | #{agent.id} | #{request.headers}")
  # end

  # PasskeysRails uses webauthn to help with the protocol.
  # The following settings are passed throught webauthn.
  # wa_origin is the only one requried

  # This value needs to match `window.location.origin` evaluated by
  # the User Agent during registration and authentication ceremonies.
  # c.wa_origin = ENV['DEFAULT_HOST'] || https://myapp.mydomain.com

  # Relying Party name for display purposes
  # c.wa_relying_party_name = "My App Name"

  # Optionally configure a client timeout hint, in milliseconds.
  # This hint specifies how long the browser should wait for any
  # interaction with the user.
  # This hint may be overridden by the browser.
  # https://www.w3.org/TR/webauthn/#dom-publickeycredentialcreationoptions-timeout
  # c.wa_credential_options_timeout = 120_000

  # You can optionally specify a different Relying Party ID
  # (https://www.w3.org/TR/webauthn/#relying-party-identifier)
  # if it differs from the default one.
  #
  # In this case the default would be "auth.example.com", but you can set it to
  # the suffix "example.com"
  #
  # c.wa_rp_id = "example.com"

  # Configure preferred binary-to-text encoding scheme. This should match the encoding scheme
  # used in your client-side (user agent) code before sending the credential to the server.
  # Supported values: `:base64url` (default), `:base64` or `false` to disable all encoding.
  #
  # c.wa_encoding = :base64url

  # Possible values: "ES256", "ES384", "ES512", "PS256", "PS384", "PS512", "RS256", "RS384", "RS512", "RS1"
  # Default: ["ES256", "PS256", "RS256"]
  #
  # c.wa_algorithms = ["ES256", "PS256", "RS256"]

  # Append an algorithm to the existing set
  # c.wa_algorithm = "PS512"
end
