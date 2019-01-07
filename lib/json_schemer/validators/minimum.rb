# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Minimum < Validator
      def valid?(instance, instance_location)
        return true unless instance.is_a?(Numeric)

        instance >= value
      end
    end
  end
end
