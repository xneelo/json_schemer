# frozen_string_literal: true
module JSONSchemer
  module Validators
    class AllOf < Validator
      def validate(instance, instance_location)
        validate_children(instance, instance_location, :all?)
      end

    private

      def children
        value.each_with_index { |schema, index| yield subschema(schema, index) }
      end
    end
  end
end
