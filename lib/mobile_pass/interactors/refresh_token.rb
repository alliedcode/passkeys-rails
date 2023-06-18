# Finish authentication ceremony
class MobilePass::RefreshToken
  include Interactor

  delegate :token, to: :context

  def call
    user = MobilePass::ValidateAuthToken.call!(auth_token: token).user

    context.username = user.username
    context.auth_token = MobilePass::GenerateAuthToken.call!(user:).auth_token
  end
end
