require 'mobile_pass'

MobilePass.config do |c|
  # The parent controller from which all MobilePass controllers inherit.
  # Defaults to ApplicationController. This should be set early
  # in the initialization process and should be set to a string.
  # Default is ApplicationController
  # c.parent_controller = "ApplicationController"

  # Secret used to encode the auth token.
  # Changing this value will invalidate all tokens that have been fetched
  # through the API.
  # Default is the application's `secret_key_base`.  You can change it below
  # and use your own secret key.
  # c.auth_token_secret = '<%= SecureRandom.hex(64) %>'

  # Algorithm used to generate the auth token.
  # Changing this value will invalidate all tokens that have been fetched
  # through the API.
  # Default is HS256
  # c.auth_token_algorithm = "HS256"

  # How long the auth token is valid before requiring a refresh or new login.
  # Set it to 0 for no expiration (not recommended in production).
  # Default is 30 days
  # c.auth_token_expiration = 30.days.from_now
end
