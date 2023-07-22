module Requests
  module APIHelpers
    def headers
      @headers ||= response.headers
    end
    alias response_headers headers

    def success
      expect(json['error_message']).to be_nil if json.is_a? Hash
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
      fields = json.dig(:error, :fields)
      expect(fields.be_a(Hash)).to be_truthy if fields
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
  end
end
