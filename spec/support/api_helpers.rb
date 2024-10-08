module Requests
  module APIHelpers
    def headers
      @headers ||= response.headers
    end
    alias response_headers headers

    def success
      expect(error.compact).to be_blank # get better spec output
      expect(error.compact).to be_empty
      expect(response).to be_successful
    end

    # alias of success
    def expect_success
      success
    end

    def error
      if error_fields.present?
        [error_context&.to_sym, error_code, error_message, error_fields]
      else
        [error_context&.to_sym, error_code, error_message]
      end
    end

    def error_context
      json.is_a?(Hash) ? json.dig(:error, :context) : nil
    end

    def error_code
      json.is_a?(Hash) ? json.dig(:error, :code) : nil
    end

    def error_message
      json.is_a?(Hash) ? json.dig(:error, :message) : nil
    end

    def error_fields
      return unless json.is_a?(Hash)

      fields = json.dig(:error, :fields)
      expect(fields).to be_a(Hash) if fields
      fields
    end

    RSpec.shared_context 'with api params' do
      let(:params) { required_params.merge(optional_params).to_json }
      let(:optional_params) { {} }
      let(:required_params) { {} }
      let(:additional_headers) { {} }

      let(:headers) { { 'Content-Type': 'application/json' }.merge(additional_headers) }
    end

    RSpec.shared_examples 'an api that requires some params' do
      it 'returns a validation error' do
        expect(call_api && error).to match [:authentication, 'missing_parameter', /.+ is missing/]
      end
    end

    RSpec.shared_examples "a failing call" do |code, message|
      it "with a resulting code and message" do
        result = call
        expect(result).to be_failure
        expect(result.code).to eq code
        expect(result.message).to match(message)
      end
    end

    RSpec.shared_examples 'a notifier' do |notification|
      it 'notifies subscribers' do
        result = {}

        sub = PasskeysRails.subscribe(notification) do |name, agent, request|
          result = { name:, agent:, request: }
        end

        call_api
        expect_success

        expect(result[:name].to_s).to eq notification.to_s
        expect(result[:agent]).to be_a PasskeysRails::Agent
        expect(result[:request]).to be_an ActionDispatch::Request

        ActiveSupport::Notifications.unsubscribe(sub)
      end
    end
  end
end
