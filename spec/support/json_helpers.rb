module Requests
  module JsonHelpers
    def json
      json = JSON.parse(response.body)
      json.is_a?(Hash) ? json.with_indifferent_access : json
    end
  end
end
