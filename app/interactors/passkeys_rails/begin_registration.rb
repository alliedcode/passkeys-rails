module PasskeysRails
  class BeginRegistration
    include Interactor

    delegate :username, to: :context

    def call
      agent = create_or_replace_unregistered_agent

      context.options = WebAuthn::Credential.options_for_create(user: { id: agent.webauthn_identifier, name: agent.username })
    end

    private

    def create_or_replace_unregistered_agent
      context.fail! code: :origin_error, message: "config.wa_origin must be set" if WebAuthn.configuration.origin.blank?

      Agent.unregistered.where(username:).destroy_all

      agent = Agent.create(username:, webauthn_identifier: WebAuthn.generate_user_id)

      context.fail!(code: :validation_errors, message: agent.errors.full_messages.to_sentence) unless agent.valid?

      agent
    end
  end
end
