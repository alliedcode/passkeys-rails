# Finish registration ceremony
class MobilePass::FinishRegistration
  include Interactor

  delegate :credential, :username, :challenge, to: :context

  def call
    verify_credential!
    store_passkey_and_register_user!

    context.user_name = user.username
    context.auth_token = MobilePass::GenerateAuthToken.call!(user:).auth_token
  end

  private

  def verify_credential!
    webauthn_credential.verify(challenge)
  rescue WebAuthn::Error => e
    context.fail!(code: :webauthn_error, message: e.message)
  end

  def store_passkey_and_register_user!
    user.transaction do
      # Store Credential ID, Credential Public Key and Sign Count for future authentications
      user.passkeys.create!(
        identifier: webauthn_credential.id,
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count
      )

      user.update! registered_at: Time.current
    end
  rescue StandardError => e
    context.fail! code: :passkey_error, message: e.message
  end

  def webauthn_credential
    @webauthn_credential ||= WebAuthn::Credential.from_create(credential)
  end

  def user
    @user ||= begin
      user = User.find_by(username:)
      context.fail!(code: :user_not_found, message: "User not found for session value: \"#{username}\"") if user.blank?

      user
    end
  end
end
