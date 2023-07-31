module PasskeysRails
  module AuthenticatableCreator
    extend ActiveSupport::Concern

    protected

    def create_authenticatable!
      authenticatable = aux_class.new
      authenticatable.agent = agent if authenticatable.respond_to?(:agent=)
      authenticatable.registering_with(authenticatable_params) if authenticatable.respond_to?(:registering_with)
      authenticatable.save!

      agent.update!(authenticatable:)
    rescue ActiveRecord::RecordInvalid => e
      context.fail!(code: :record_invalid, message: e.message)
    end

    def aux_class_name
      @aux_class_name ||= authenticatable_class || PasskeysRails.default_class
    end

    private

    def authenticatable_class
      authenticatable_info && authenticatable_info[:class]
    end

    def authenticatable_params
      authenticatable_info && authenticatable_info[:params]
    end

    def aux_class
      whitelist = PasskeysRails.class_whitelist

      @aux_class ||= begin
        if whitelist.is_a?(Array)
          unless whitelist.include?(aux_class_name)
            context.fail!(code: :invalid_authenticatable_class, message: "authenticatable_class (#{aux_class_name}) is not in the whitelist")
          end
        elsif whitelist.present?
          context.fail!(code: :invalid_class_whitelist,
                        message: "class_whitelist is invalid.  It should be nil or an array of zero or more class names.")
        end

        begin
          aux_class_name.constantize
        rescue StandardError
          context.fail!(code: :invalid_authenticatable_class, message: "authenticatable_class (#{aux_class_name}) is not defined")
        end
      end
    end
  end
end
