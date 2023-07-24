module PasskeysRails
  module Authentication
    extend ActiveSupport::Concern

    included do
      rescue_from PasskeysRails::Error do |e|
        render json: e.to_h, status: :unauthorized
      end
    end

    def current_agent
      @current_agent ||= (request.headers['HTTP_X_AUTH'].present? &&
                         passkey_authentication_result.success? &&
                         passkey_authentication_result.agent.registered? &&
                         passkey_authentication_result.agent) || nil
    end

    def authenticate_passkey!
      return if current_agent.present?

      raise PasskeysRails::Error.new(:authentication,
                                     code: :unauthorized,
                                     message: "You are not authorized to access this resource.")
    end

    def passkey_authentication_result
      @passkey_authentication_result ||= PasskeysRails::ValidateAuthToken.call(auth_token: request.headers['HTTP_X_AUTH'])
    end
  end
end
