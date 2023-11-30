# rubocop:disable Naming/FileName
require 'passkeys_rails/engine'
require 'passkeys_rails/configuration'
require 'passkeys_rails/version'
require_relative "generators/passkeys_rails/install_generator"
require 'forwardable'

module PasskeysRails
  module Test
    autoload :IntegrationHelpers, 'passkeys_rails/test/integration_helpers'
  end

  class << self
    extend Forwardable

    def_delegators :config, :auth_token_secret, :auth_token_algorithm, :auth_token_expires_in, :default_class, :class_whitelist

    def config
      @config ||= begin
        config = Configuration.new
        yield(config) if block_given?
        apply_webauthn_configuration(config)

        config
      end
    end
  end

  def self.apply_webauthn_configuration(config)
    WebAuthn.configure do |c|
      c.origin = config.wa_origin
      c.rp_name = config.wa_relying_party_name if config.wa_relying_party_name
      c.credential_options_timeout = config.wa_credential_options_timeout if config.wa_credential_options_timeout
      c.rp_id = config.wa_rp_id if config.wa_rp_id
      c.encoding = config.wa_encoding if config.wa_encoding
      c.algorithms = config.wa_algorithms if config.wa_algorithms
      c.algorithms << config.wa_algorithm if config.wa_algorithm
    end
  end

  # Convenience method to subscribe to various events in PasskeysRails.
  #
  # Valid events:
  #   :did_register
  #   :did_authenticate
  #   :did_refresh
  #
  # Each event will include the event name, current agent and http request.
  # For example:
  #
  # subscribe(:did_register) do |event, agent, request|
  #   # do something with the agent and/or request
  # end
  #
  def self.subscribe(event_name)
    ActiveSupport::Notifications.subscribe("passkeys_rails.#{event_name}") do |name, _start, _finish, _id, payload|
      yield(name.gsub(/^passkeys_rails\./, ''), payload[:agent], payload[:request]) if block_given?
    end
  end

  # This is only used by the debug_login endpoint.
  # CAUTION: It is very insecure to set DEBUG_LOGIN_REGEX in a production environment.
  def self.debug_login_regex
    ENV['DEBUG_LOGIN_REGEX'].present? ? Regexp.new(ENV['DEBUG_LOGIN_REGEX']) : nil
  end

  # Returns an Interactor::Context that indicates if the request is authentic.
  #
  # `request` can be a String on an Http Request
  #
  # .success? is true if authentic
  # .agent is the Passkey::Agent on success
  #
  # .failure? is true if failed (just the opposite of .success?)
  # .code is the error code on failure
  # .message is the human readable error message on failure
  def self.authenticate(request)
    auth_token = if request.is_a?(String)
                   request
                 elsif request.respond_to?(:headers)
                   request.headers['X-Auth']
                 else
                   ""
                 end

    PasskeysRails::ValidateAuthToken.call(auth_token:)
  end

  # Raises a PasskeysRails::Error exception if the request is not authentic.
  # `request` can be a String on an Http Request
  def self.authenticate!(request)
    auth = authenticate(request)
    return if auth.success?

    raise PasskeysRails::Error.new(:authentication,
                                   code: auth.code,
                                   message: auth.message)
  end

  require 'passkeys_rails/railtie' if defined?(Rails)
end
# rubocop:enable Naming/FileName
