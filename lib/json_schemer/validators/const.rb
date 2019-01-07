# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Const < Validator
      def valid?(instance, instance_location)
        instance == value
      end
    end
  end
end
