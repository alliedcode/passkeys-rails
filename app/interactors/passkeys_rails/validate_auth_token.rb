module PasskeysRails
  class ValidateAuthToken
    include Interactor

    delegate :auth_token, to: :context

    def call
      context.fail!(code: :missing_token, message: "X-Auth header is required") if auth_token.blank?

      context.agent = fetch_agent
    end

    private

    def fetch_agent
      agent = Agent.find_by(id: payload['agent_id'])
      context.fail!(code: :invalid_token, message: "Invalid token - no agent exists with agent_id") if agent.blank?

      agent
    end

    def payload
      JWT.decode(auth_token,
                 PasskeysRails.auth_token_secret,
                 true,
                 { required_claims: %w[exp agent_id], algorithm: PasskeysRails.auth_token_algorithm }).first
    rescue JWT::ExpiredSignature
      context.fail!(code: :expired_token, message: "The token has expired")
    rescue StandardError => e
      context.fail!(code: :token_error, message: e.message)
    end
  end
end
