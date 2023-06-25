module PasskeysRails
  class ErrorMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        response = @app.call(env)
      rescue Error => e
        return [401, { 'Content-Type' => 'application/json' }, e.to_h.to_json]
      end

      response
    end
  end
end
