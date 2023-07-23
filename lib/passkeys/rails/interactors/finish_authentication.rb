# Finish authentication ceremony
module Passkeys
  module Rails
    class FinishAuthentication
      include Interactor

      delegate :credential, :challenge, to: :context

      def call
        verify_credential!

        context.username = agent.username
        context.auth_token = GenerateAuthToken.call!(agent:).auth_token
      rescue Interactor::Failure => e
        context.fail! code: e.context.code, message: e.context.message
      end

      private

      def verify_credential!
        webauthn_credential.verify(
          challenge,
          public_key: passkey.public_key,
          sign_count: passkey.sign_count
        )

        passkey.update!(sign_count: webauthn_credential.sign_count)
        agent.update!(last_authenticated_at: Time.current)
      rescue WebAuthn::SignCountVerificationError
        # Cryptographic verification of the authenticator data succeeded, but the signature counter was less than or equal
        # to the stored value. This can have several reasons and depending on your risk tolerance you can choose to fail or
        # pass authentication. For more information see https://www.w3.org/TR/webauthn/#sign-counter
      rescue WebAuthn::Error => e
        context.fail!(code: :webauthn_error, message: e.message)
      end

      def webauthn_credential
        @webauthn_credential ||= WebAuthn::Credential.from_get(credential)
      end

      def passkey
        @passkey ||= begin
          passkey = Passkey.find_by(identifier: webauthn_credential.id)
          context.fail!(code: :passkey_not_found, message: "Unable to find the specified passkey") if passkey.blank?

          passkey
        end
      end

      def agent
        passkey.agent
      end
    end
  end
end
