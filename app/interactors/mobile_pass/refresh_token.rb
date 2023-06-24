# Finish authentication ceremony
module MobilePass
  class RefreshToken
    include Interactor

    delegate :token, to: :context

    def call
      agent = ValidateAuthToken.call!(auth_token: token).agent

      context.username = agent.username
      context.auth_token = GenerateAuthToken.call!(agent:).auth_token
    rescue Interactor::Failure => e
      context.fail! code: e.context.code, message: e.context.message
    end
  end
end
