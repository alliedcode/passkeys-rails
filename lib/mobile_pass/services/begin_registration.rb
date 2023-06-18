class MobilePass::BeginRegistration
  include Interactor

  delegate :username, to: :context

  def call
    user = create_unregistered_user

    context.options = WebAuthn::Credential.options_for_create(user: { id: user.webauthn_identifier, name: user.username })
  end

  private

  def create_unregistered_user
    user = User.create(username:, webauthn_identifier: WebAuthn.generate_user_id)

    context.fail!(code: :validation_errors, message: "Username is already in use") if user.blank?
    context.fail!(code: :validation_errors, message: user.errors.full_messages.to_sentence) unless user.persisted?

    user
  end
end
