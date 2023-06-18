# Finish authentication ceremony
class MobilePass::FinishAuthentication
  include Interactor

  delegate :credential, :challenge, to: :context

  def call
    webauthn_credential = WebAuthn::Credential.from_get(credential)

    passkey = Passkey.find_by(identifier: webauthn_credential.id)
    context.fail!(code: :passkey_not_found, message: "Unable to find the specified passkey") if passkey.blank?

    begin
      webauthn_credential.verify(
        challenge,
        public_key: passkey.public_key,
        sign_count: passkey.sign_count
      )

      passkey.update!(sign_count: webauthn_credential.sign_count)
    rescue WebAuthn::SignCountVerificationError
      # Cryptographic verification of the authenticator data succeeded, but the signature counter was less than or equal
      # to the stored value. This can have several reasons and depending on your risk tolerance you can choose to fail or
      # pass authentication. For more information see https://www.w3.org/TR/webauthn/#sign-counter
    rescue WebAuthn::Error => e
      context.fail!(code: :webauthn_error, message: e.message)
    end

    user = passkey.user

    context.user_name = user.username
    context.auth_token = auth_token(user)
  end

  private

  def auth_token(user)
    result = MobilePass::AuthToken.call(user:)

    context.fail!(code: :token_generation_failed, message: "Unable to generate auth token") if result.failure?

    result.auth_token
  end
end
