class MobilePass::BeginChallenge
  include Interactor

  delegate :username, to: :context

  def call
    result = generate_challenge

    options = result.options

    context.response = options
    context.session_data = session_data(options)
  end

  private

  def generate_challenge
    result = if username.present?
               MobilePass::BeginRegistration.call(username:)
             else
               MobilePass::BeginAuthentication.call
             end

    context.fail!(code: result.code, message: result.message) if result.failure?

    result
  end

  def session_data(options)
    {
      username:,
      challenge: WebAuthn.standard_encoder.encode(options.challenge)
    }
  end
end
