module Passkeys
  module Rails
    class BeginRegistration
      include Interactor

      delegate :username, to: :context

      def call
        agent = create_unregistered_agent

        context.options = WebAuthn::Credential.options_for_create(user: { id: agent.webauthn_identifier, name: agent.username })
      end

      private

      def create_unregistered_agent
        agent = Agent.create(username:, webauthn_identifier: WebAuthn.generate_user_id)

        context.fail!(code: :validation_errors, message: agent.errors.full_messages.to_sentence) unless agent.valid?

        agent
      end
    end
  end
end
