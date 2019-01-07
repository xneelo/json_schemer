# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Required < Validator
      def valid?(instance, instance_location)
        return true unless instance.is_a?(Hash)

        value.all? { |key| instance.key?(key) }
      end
    end
  end
end
