module Passkeys::Rails
  class Error < StandardError
    attr_reader :hash

    def initialize(message, hash = {})
      @hash = hash
      super(message)
    end

    def to_h
      { error: hash.merge(context: message) }
    end
  end
end
