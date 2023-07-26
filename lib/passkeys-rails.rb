# rubocop:disable Naming/FileName
require 'passkeys_rails/engine'
require 'passkeys_rails/version'
require_relative "generators/passkeys_rails/install_generator"

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

  # Model to use when creating or authenticating a passkey.
  # This can be overridden when calling the API, but if no
  # value is supplied when calling the API, this value is used.
  # If nil, there is no default, and if none is supplied when
  # calling the API, no resource is created other than
  # a PaskeysRails::Agent that is used to track the passkey.
  #
  # This library doesn't assume that there will only be one
  # model, but it is a common use case, so setting the
  # default_class simplifies the use of the API in that case.
  mattr_accessor :default_class, default: "User"

  # By providing a class_whitelist, the API will require that
  # any supplied class is in the whitelist.  If it is not, the
  # auth API will return an error.  This prevents a caller from
  # attempting to create an unintended record on registration.
  # If nil, any model will be allowed.
  # If [], no model will be allowed.
  # This should be an array of symbols or strings,
  # for example: %w[User AdminUser]
  mattr_accessor :class_whitelist, default: nil

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
# rubocop:enable Naming/FileName
