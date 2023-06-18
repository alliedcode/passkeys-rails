# frozen_string_literal: true

require_relative "mobile_pass/version"
require_relative "mobile_pass/engine"
require "rails"
require "active_support/core_ext/numeric/time"
require "active_support/dependencies"
require "interactor"
require "jwt"
require "webauthn"

module MobilePass
  autoload :Error, "mobile_pass/error"

  autoload :BeginChallenge, "mobile_pass/interactors/begin_challenge"
  autoload :BeginAuthentication, "mobile_pass/interactors/begin_authentication"
  autoload :BeginRegistration, "mobile_pass/interactors/begin_registration"
  autoload :FinishAuthentication, "mobile_pass/interactors/finish_authentication"
  autoload :FinishRegistration, "mobile_pass/interactors/finish_registration"

  autoload :AuthToken, "mobile_pass/interactors/auth_token"
  autoload :ValidateAuthToken, "mobile_pass/interactors/validate_auth_token"
  autoload :RefreshToken, "mobile_pass/interactors/refresh_token"

  class << self
    # The parent controller from which all MobilePass controllers inherit.
    # Defaults to ApplicationController. This should be set early
    # in the initialization process and should be set to a string.
    attr_writer :parent_controller

    # Secret used to encode the auth token.
    # Rails.application.secret_key_base is used if none is defined here.
    # Changing this value will invalidate all tokens that have been fetched
    # through the API.
    attr_writer :auth_token_secret

    # Algorithm used to generate the auth token.
    # Changing this value will invalidate all tokens that have been fetched
    # through the API.
    attr_writer :auth_token_algorithm

    # How long the auth token is valid before requiring a refresh or new login.
    # Set it to 0 for no expiration (not recommended in production).
    attr_writer :auth_token_expiration

    def config
      yield self
    end

    def parent_controller
      @_parent_controller ||= "ApplicationController"
    end

    def auth_token_secret
      @_auth_token_secret ||= Rails.application.secret_key_base
    end

    def auth_token_algorithm
      @_auth_token_algorithm ||= "HS256"
    end

    def auth_token_expiration
      @_auth_token_expiration ||= 30.days.from_now
    end
  end
end
