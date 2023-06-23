module MobilePass
  class ApplicationController < MobilePass.parent_controller.constantize
    rescue_from Error, with: :handle_mobile_pass_error
    rescue_from ::Interactor::Failure, with: :handle_interactor_failure
    rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

    if respond_to?(:helper_method)
      helpers = %w[current_user authenticate_user!]
      helper_method(*helpers)
    end

    protected

    def current_user
      return nil if headers['X-Auth'].blank?

      @current_user ||= validated_auth_token!.user
    end

    def authenticate_user!
      validated_auth_token!.success?
    end

    def validated_auth_token!
      @validated_auth_token ||= ValidateAuthToken.call!(auth_token: headers['X-Auth'])
    end

    def handle_missing_parameter(error)
      render json: Error.new(:authentication, { code: 'missing_parameter', message: error.message }).to_h, status: :unprocessable_entity
    end

    def handle_interactor_failure(failure)
      render json: Error.new(:authentication, failure.context.to_h.slice(:code, :message)).to_h, status: :unprocessable_entity
    end

    def handle_mobile_pass_error(err)
      render json: err.to_h, status: :unprocessable_entity
    end
  end
end
