# Finish registration ceremony
module PasskeysRails
  class FinishRegistration
    include Interactor
    include AuthenticatableCreator

    delegate :credential, :username, :challenge, :authenticatable_info, to: :context

    def call
      verify_credential!

      agent.transaction do
        store_passkey_and_register_agent!
        create_authenticatable! if aux_class_name.present?
      end

      context.username = agent.username
      context.auth_token = GenerateAuthToken.call!(agent:).auth_token
    rescue Interactor::Failure => e
      context.fail! code: e.context.code, message: e.context.message
    end

    private

    def verify_credential!
      webauthn_credential.verify(challenge)
    rescue WebAuthn::Error => e
      context.fail!(code: :webauthn_error, message: e.message)
    rescue StandardError => e
      context.fail!(code: :error, message: e.message)
    end

    def store_passkey_and_register_agent!
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
