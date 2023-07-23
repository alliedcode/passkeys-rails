require_relative "passkeys_rails/version"
require_relative "generators/passkeys_rails/install_generator"
require "rails"
require "active_support/core_ext/numeric/time"
require "active_support/dependencies"
require "interactor"
require "jwt"
require "webauthn"
require_relative "passkeys_rails/engine"

module PasskeysRails
  # Secret used to encode the auth token.
  # Rails.application.secret_key_base is used if none is defined here.
  # Changing this value will invalidate all tokens that have been fetched
  # through the API.
  mattr_accessor(:auth_token_secret)

  # Algorithm used to generate the auth token.
  # Changing this value will invalidate all tokens that have been fetched
  # through the API.
  mattr_accessor :auth_token_algorithm, default: "HS256"

  # How long the auth token is valid before requiring a refresh or new login.
  # Set it to 0 for no expiration (not recommended in production).
  mattr_accessor :auth_token_expires_in, default: 30.days

  class << self
    def config
      yield self
    end
  end

  require 'passkeys_rails/railtie' if defined?(Rails)
end

ActiveSupport.on_load(:before_initialize) do
  PasskeysRails.auth_token_secret ||= Rails.application.secret_key_base
end
