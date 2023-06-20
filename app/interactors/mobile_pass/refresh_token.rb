# Finish authentication ceremony
module MobilePass
  class RefreshToken
    include Interactor

    delegate :token, to: :context

    def call
      agent = ValidateAuthToken.call!(auth_token: token).agent

      context.username = agent.username
      context.auth_token = GenerateAuthToken.call!(agent:).auth_token
    end
  end
end
