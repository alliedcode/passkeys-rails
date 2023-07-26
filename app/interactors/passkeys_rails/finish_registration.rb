# Finish registration ceremony
module PasskeysRails
  class FinishRegistration
    include Interactor

    delegate :credential, :username, :challenge, :authenticatable_info, to: :context

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
    rescue WebAuthn::Error => e
      context.fail!(code: :webauthn_error, message: e.message)
    rescue StandardError => e
      context.fail!(code: :error, message: e.message)
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

        create_authenticatable! if aux_class_name.present?
      end
    end

    def authenticatable_class
      authenticatable_info && authenticatable_info[:class]
    end

    def authenticatable_params
      authenticatable_info && authenticatable_info[:params]
    end

    def aux_class_name
      @aux_class_name ||= authenticatable_class || PasskeysRails.default_class
    end

    def aux_class
      whitelist = PasskeysRails.class_whitelist

      @aux_class ||= begin
        if whitelist.is_a?(Array)
          unless whitelist.include?(aux_class_name)
            context.fail!(code: :invalid_authenticatable_class, message: "authenticatable_class (#{aux_class_name}) is not in the whitelist")
          end
        elsif whitelist.present?
          context.fail!(code: :invalid_class_whitelist,
                        message: "class_whitelist is invalid.  It should be nil or an array of zero or more class names.")
        end

        begin
          aux_class_name.constantize
        rescue StandardError
          context.fail!(code: :invalid_authenticatable_class, message: "authenticatable_class (#{aux_class_name}) is not defined")
        end
      end
    end

    def create_authenticatable!
      authenticatable = aux_class.create! do |obj|
        obj.agent = agent if obj.respond_to?(:agent=)
        obj.registering_with(authenticatable_params) if obj.respond_to?(:registering_with)
      end

      agent.update!(authenticatable:)
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(code: :record_invalid, message: e.message)
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
