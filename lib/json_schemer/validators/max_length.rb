# frozen_string_literal: true
module JSONSchemer
  module Validators
    class MaxLength < Validator
      def valid?(instance, instance_location)
        return true unless instance.is_a?(String)

        instance.size <= value
      end
    end
  end
end
