module MobilePass
  module ApplicationHelper
    def current_agent
      return nil if request.headers['HTTP_X_AUTH'].blank?

      @current_agent ||= validated_auth_token&.success? && validated_auth_token&.agent
    end

    def authenticate!
      return if validated_auth_token.success?

      raise MobilePass::Error.new(:authentication,
                                  code: :unauthorized,
                                  message: "You are not authorized to access this resource.")
    end

    def validated_auth_token
      @validated_auth_token ||= ValidateAuthToken.call(auth_token: request.headers['HTTP_X_AUTH'])
    end
  end
end