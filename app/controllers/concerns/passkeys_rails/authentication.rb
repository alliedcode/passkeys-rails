module PasskeysRails
  module Authentication
    extend ActiveSupport::Concern

    included do
      rescue_from PasskeysRails::Error do |e|
        render json: e.to_h, status: :unauthorized
      end
    end

    def current_agent
      @current_agent ||= (passkey_authentication_result.success? &&
                         passkey_authentication_result.agent.registered? &&
                         passkey_authentication_result.agent) || nil
    end

    def authenticate_passkey!
      @authenticate_passkey ||= PasskeysRails.authenticate!(request)
    end

    def passkey_authentication_result
      @passkey_authentication_result ||= PasskeysRails.authenticate(request)
    end
  end
end
