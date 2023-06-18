class MobilePassController < MobilePass.parent_controller.constantize
  rescue_from MobilePass::Error, with: :handle_exception

  if respond_to?(:helper_method)
    helpers = %w[authenticate_user!]
    helper_method(*helpers)
  end

  protected

  def authenticate_user!
    # TODO
  end

  def fail!(context, code, message)
    raise MobilePass::Error.new(context, code, message)
  end

  def handle_exception(e)
    render json: { error: { context: e.context, code: e.code, message: e.message } }, status: :unprocessable_entity
  end
end
