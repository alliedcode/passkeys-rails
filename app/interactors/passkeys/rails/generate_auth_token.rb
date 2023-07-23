module Passkeys::Rails
  class GenerateAuthToken
    include Interactor

    delegate :agent, to: :context

    def call
      context.auth_token = generate_auth_token
    end

    private

    def generate_auth_token
      JWT.encode(jwt_payload,
                 Passkeys::Rails.auth_token_secret,
                 Passkeys::Rails.auth_token_algorithm)
    end

    def jwt_payload
      expiration = (Time.current + Passkeys::Rails.auth_token_expires_in).to_i

      payload = { agent_id: agent.id }
      payload[:exp] = expiration unless expiration.zero?
      payload
    end
  end
end
