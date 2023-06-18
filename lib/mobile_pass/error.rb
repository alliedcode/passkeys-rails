module MobilePass
  class Error < StandardError
    attr_reader :context, :code
    def initialize(context, code, message)
      @context = context
      @code = code
      super(message)
    end
  end
end
