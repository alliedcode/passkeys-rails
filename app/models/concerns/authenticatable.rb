require 'active_support/concern'

module MobilePass
  class BeginAuthentication
    extend ActiveSupport::Concern

    included do
      has_one :agent, as: :mobile_pass_authenticatable, optional: true
      def registered?
        registred_at.present?
      end
    end
  end
end
