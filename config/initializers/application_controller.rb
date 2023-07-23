# These should be autoloaded, but if these aren't required here, apps using this
# gem will throw an exception that PasskeysRails::Authentication can't be found
require_relative '../../app/controllers/concerns/passkeys_rails/authentication'
require_relative '../../app/models/passkeys_rails/error'

class ActionController::Base
  include PasskeysRails::Authentication
end

class ActionController::API
  include PasskeysRails::Authentication
end
