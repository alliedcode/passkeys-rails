class MobilePassController < MobilePass.parent_controller.constantize
  rescue_from MobilePass::Error, with: :handle_mobile_pass_error
  rescue_from Interactor::Failure, with: :handle_interactor_failure

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
    @validated_auth_token ||= MobilePass::ValidateAuthToken.call!(auth_token: headers['X-Auth'])
  end

  def handle_interactor_failure(context)
    raise MobilePass::Error.new(:authentication, context.to_h)
  end

  def handle_mobile_pass_error(err)
    render json: err.to_h, status: :unprocessable_entity
  end
end
