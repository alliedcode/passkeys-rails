require 'active_support/concern'

module PasskeysRails
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      has_one :agent, as: :authenticatable, class_name: "PasskeysRails::Agent"

      delegate :username, to: :agent, allow_nil: true
      delegate :registered?, to: :agent, allow_nil: true

      def registering_with(_params)
        # initialize required attributes
      end
    end
  end
end
