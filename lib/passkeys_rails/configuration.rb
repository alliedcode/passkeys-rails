module PasskeysRails
  class Configuration
    # Secret used to encode the auth token.
    # Rails.application.secret_key_base is used if none is defined here.
    # Changing this value will invalidate all tokens that have been fetched
    # through the API.
    attr_accessor :auth_token_secret

    # Algorithm used to generate the auth token.
    # Changing this value will invalidate all tokens that have been fetched
    # through the API.
    attr_accessor :auth_token_algorithm

    # How long the auth token is valid before requiring a refresh or new login.
    # Set it to 0 for no expiration (not recommended in production).
    attr_accessor :auth_token_expires_in

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
    attr_accessor :default_class

    # By providing a class_whitelist, the API will require that
    # any supplied class is in the whitelist.  If it is not, the
    # auth API will return an error.  This prevents a caller from
    # attempting to create an unintended record on registration.
    # If nil, any model will be allowed.
    # If [], no model will be allowed.
    # This should be an array of symbols or strings,
    # for example: %w[User AdminUser]
    attr_accessor :class_whitelist

    # webauthn settings
    attr_accessor :wa_origin,
                  :wa_relying_party_name,
                  :wa_credential_options_timeout,
                  :wa_rp_id,
                  :wa_encoding,
                  :wa_algorithms,
                  :wa_algorithm

    def initialize
      # defaults
      @auth_token_secret = Rails.application.secret_key_base
      @auth_token_algorithm = "HS256"
      @auth_token_expires_in = 30.days
      @default_class = "User"
      @wa_origin = "https://example.com"
    end

    def subscribe(event_name)
      PasskeysRails.subscribe(event_name)
    end
  end
end
