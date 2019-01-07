# frozen_string_literal: true
module JSONSchemer
  module Validators
    class MaxItems < Validator
      def valid?(instance, instance_location)
        return true unless instance.is_a?(Array)

        instance.size <= value
      end
    end
  end
end
