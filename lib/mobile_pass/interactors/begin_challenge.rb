class MobilePass::BeginChallenge
  include Interactor

  delegate :username, to: :context

  def call
    result = generate_challenge!

    options = result.options

    context.response = options
    context.session_data = session_data(options)
  end

  private

  def generate_challenge!
    if username.present?
      MobilePass::BeginRegistration.call!(username:)
    else
      MobilePass::BeginAuthentication.call!
    end
  end

  def session_data(options)
    {
      username:,
      challenge: WebAuthn.standard_encoder.encode(options.challenge)
    }
  end
end
