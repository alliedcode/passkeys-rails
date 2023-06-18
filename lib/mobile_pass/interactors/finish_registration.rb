# Finish registration ceremony
class MobilePass::FinishRegistration
  include Interactor

  delegate :credential, :username, :challenge, to: :context

  def call
    webauthn_credential = WebAuthn::Credential.from_create(credential)

    begin
      webauthn_credential.verify(challenge)

      user = User.find_by(username:)

      context.fail!(code: :user_not_found, message: "User not found for session value: \"#{username}\"") if user.blank?

      user.transaction do
        # Store Credential ID, Credential Public Key and Sign Count for future authentications
        user.passkeys.create!(
          identifier: webauthn_credential.id,
          public_key: webauthn_credential.public_key,
          sign_count: webauthn_credential.sign_count
        )

        user.update! registered_at: Time.current
      end

      context.user_name = user.username
      context.auth_token = MobilePass::GenerateAuthToken.call!(user:).auth_token
    rescue WebAuthn::Error => e
      context.fail!(code: :webauthn_error, message: e.message)
    end
  end
end
