class ValidateAuthToken
  include Interactor

  delegate :auth_token, to: :context

  def call
    context.user = fetch_user
  end

  private

  def fetch_user
    user_id = payload['user_id']
    context.fail!(code: :invalid_token, message: "Invalid token - user_id is missing") if user_id.blank?

    user = User.find_by(id: user_id)
    context.fail!(code: :invalid_token, message: "Invalid token - no user exists with user_id") if user.blank?

    user
  end

  def payload
    JWT.decode(auth_token,
               MobilePass.auth_token_secret,
               MobilePass.auth_token_algorithm).first
  rescue JWT::ExpiredSignature
    context.fail!(code: :expired_token, message: "The token has expired")
  rescue StandardError => e
    context.fail!(code: :token_error, message: e.message)
  end
end
