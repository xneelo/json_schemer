# frozen_string_literal: true
module JSONSchemer
  module Validators
    class MultipleOf < Validator
      def valid?(instance, instance_location)
        return true unless instance.is_a?(Numeric)

        quotient = instance / value.to_f
        quotient.floor == quotient
      end
    end
  end
end
