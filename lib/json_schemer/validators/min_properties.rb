# frozen_string_literal: true
module JSONSchemer
  module Validators
    class MinProperties < Validator
      def valid?(instance, instance_location)
        return true unless instance.is_a?(Hash)

        instance.size >= value
      end
    end
  end
end
