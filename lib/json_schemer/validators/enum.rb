# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Enum < Validator
      def valid?(instance, instance_location)
        value.include?(instance)
      end
    end
  end
end
