module PasskeysRails
  module Debuggable
    extend ActiveSupport::Concern

    protected

    def ensure_debug_mode
      context.fail!(code: :not_allowed, message: 'Action not allowed') if username_regex.blank?
    end

    def ensure_regex_match
      context.fail!(code: :not_allowed, message: 'Invalid username') unless username&.match?(username_regex)
    end

    def username_regex
      PasskeysRails.debug_login_regex
    end
  end
end
