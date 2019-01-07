# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Type < Validator
      BOOLEANS = [true, false].freeze

      def valid?(instance, instance_location)
        case value
        when 'null'
          instance.nil?
        when 'boolean'
          BOOLEANS.include?(instance)
        when 'number'
          instance.is_a?(Numeric)
        when 'integer'
          instance.is_a?(Numeric) && (instance.is_a?(Integer) || instance.floor == instance)
        when 'string'
          instance.is_a?(String)
        when 'array'
          instance.is_a?(Array)
        when 'object'
          instance.is_a?(Hash)
        end
      end

      def validate(instance, instance_location)
        return super unless value.is_a?(Array)
        validate_children(instance, instance_location, :any?)
      end

    private

      def children
        value.each_with_index do |type, index|
          yield self.class.new(root, self, type, "#{keyword_location}/#{index}", parent_uri)
        end
      end
    end
  end
end
