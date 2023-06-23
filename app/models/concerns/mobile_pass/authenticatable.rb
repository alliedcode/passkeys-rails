require 'active_support/concern'

module MobilePass
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      has_one :agent, as: :authenticatable
      def registered?
        registred_at.present?
      end

      def self.did_register(agent)
        agent.update!(authenticatable: create!)
      end
    end
  end
end
