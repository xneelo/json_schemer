# frozen_string_literal: true
module JSONSchemer
  module Validators
    class UniqueItems < Validator
      def valid?(instance, instance_location)
        return true unless instance.is_a?(Array)

        value && instance.size == instance.uniq.size
      end
    end
  end
end
