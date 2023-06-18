class MobilePass::GenerateAuthToken
  include Interactor

  delegate :user, to: :context

  def call
    context.auth_token = auth_token(user)
  end

  private

  def auth_token(user)
    jwt_secret = MobilePass.auth_token_secret.presence || Rails.application.secret_key_base
    jwt_algorithm = MobilePass.auth_token_algorithm

    JWT.encode(jwt_payload(user), jwt_secret, jwt_algorithm)
  end

  def jwt_payload(user)
    expiration = MobilePass.auth_token_expiration.to_i

    payload = { user_id: user.id }
    payload[:exp] = expiration unless expiration.zero?
    payload
  end
end
