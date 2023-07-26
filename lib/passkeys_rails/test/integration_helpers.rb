module PasskeysRails
  # PasskeysRails::Test::IntegrationHelpers is a helper module for facilitating
  # authentication on Rails integration tests to bypass the required steps for
  # signin in or signin out a record.
  #
  # Examples
  #
  #  class PostsTest < ActionDispatch::IntegrationTest
  #    include PasskeysRails::Test::IntegrationHelpers
  #
  #    test 'authenticated users can see posts' do
  #      get '/posts', headers: logged_in_headers('username-1')
  #      assert_response :success
  #    end
  #  end
  module Test
    module IntegrationHelpers
      def self.included(base)
        base.class_eval do
          setup :setup_integration_for_passkeys_rails
          teardown :teardown_integration_for_passkeys_rails
        end
      end

      def logged_in_headers(username, authenticatable = nil, headers: {})
        @agent = Agent.create(username:, registered_at: Time.current, authenticatable:)
        result = PasskeysRails::GenerateAuthToken.call(agent:)
        raise result.message if result.failure?

        headers.merge("X-Auth" => result.auth_token)
      end

      protected

      attr_reader :agent

      def setup_integration_for_passkeys_rails
        # Nothing to do here
      end

      def teardown_integration_for_passkeys_rails
        @agent&.destroy
      end
    end
  end
end
