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
end
