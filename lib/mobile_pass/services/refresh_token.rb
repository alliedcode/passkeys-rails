# Finish authentication ceremony
class MobilePass::RefreshToken
  include Interactor

  delegate :token, to: :context

  def call
    user = fetch_user

    context.username = user.username
    context.auth_token = auth_token(user)
  end

  private

  def fetch_user
    result = MobilePass::ValidateAuthToken.call(auth_token: token)

    fail!(code: result.code, message: result.message) if result.failure?

    result.user
  end

  def auth_token(user)
    result = MobilePass::AuthToken.call(user:)

    context.fail!(code: :token_generation_failed, message: "Unable to generate auth token") if result.failure?

    result.auth_token
  end
end
