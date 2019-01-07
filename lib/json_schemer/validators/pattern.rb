# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Pattern < Validator
      def valid?(instance, instance_location)
        return true unless instance.is_a?(String)

        ecma_262_regex(value) =~ instance
      end
    end
  end
end
