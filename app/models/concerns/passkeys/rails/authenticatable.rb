require 'active_support/concern'

module Passkeys::Rails
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      has_one :agent, as: :authenticatable

      delegate :registered?, to: :agent, allow_nil: true

      def registering_with(_agent)
        # initialize required attributes
      end
    end
  end
end
