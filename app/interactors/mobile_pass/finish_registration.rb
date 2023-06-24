# Finish registration ceremony
module MobilePass
  class FinishRegistration
    include Interactor

    delegate :credential, :username, :challenge, :authenticatable_class, to: :context

    def call
      verify_credential!
      store_passkey_and_register_agent!

      context.username = agent.username
      context.auth_token = GenerateAuthToken.call!(agent:).auth_token
    rescue Interactor::Failure => e
      context.fail! code: e.context.code, message: e.context.message
    end

    private

    def verify_credential!
      webauthn_credential.verify(challenge)
    rescue StandardError, WebAuthn::Error => e
      context.fail!(code: :webauthn_error, message: e.message)
    end

    def store_passkey_and_register_agent!
      agent.transaction do
        begin
          # Store Credential ID, Credential Public Key and Sign Count for future authentications
          agent.passkeys.create!(
            identifier: webauthn_credential.id,
            public_key: webauthn_credential.public_key,
            sign_count: webauthn_credential.sign_count
          )

          agent.update! registered_at: Time.current
        rescue StandardError => e
          context.fail! code: :passkey_error, message: e.message
        end

        create_authenticatable! if authenticatable_class.present?
      end
    end

    def create_authenticatable!
      klass = begin
        authenticatable_class.constantize
      rescue StandardError => e
        context.fail!(code: :invalid_authenticatable_class, message: "authenticatable_class (#{authenticatable_class}) is not defined")
      end

      unless klass.respond_to?(:did_register)
        context.fail!(code: :invalid_authenticatable_class,
                      message: "authenticatable_class (#{authenticatable_class}) must respond to did_register(Agent)")
      end

      klass.did_register agent
    end

    def webauthn_credential
      @webauthn_credential ||= WebAuthn::Credential.from_create(credential)
    end

    def agent
      @agent ||= begin
        agent = Agent.find_by(username:)
        context.fail!(code: :agent_not_found, message: "Agent not found for session value: \"#{username}\"") if agent.blank?

        agent
      end
    end
  end
end
