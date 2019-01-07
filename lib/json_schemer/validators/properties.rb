# frozen_string_literal: true
# this is wrong - output needs to be based on schema layout
module JSONSchemer
  module Validators
    class Properties < Validator
      def validate(instance, instance_location)
        return output(instance, instance_location, true) unless instance.is_a?(Hash)

        output(instance, instance_location, :all?) do |yielder|
          instance.each do |key, val|
            if property_names_schema
              yielder << property_names_schema.validate(key, "#{instance_location}/#{key}")
            end

            matched_key = false

            if property_schema = properties_schemas[key]
              yielder << property_schema.validate(val, "#{instance_location}/#{key}")
              matched_key = true
            end

            pattern_properties.each do |regex, property_schema|
              if regex =~ key
                yielder << property_schema.validate(val, "#{instance_location}/#{key}")
                matched_key = true
              end
            end

            if !matched_key && additional_properties_schema
              yielder << additional_properties_schema.validate(val, "#{instance_location}/#{key}")
            end
          end
        end
      end

    private

      def property_names_schema
        @property_names_schema ||= if value.key?('propertyNames')
          subschema(value.fetch('propertyNames'), 'propertyNames')
        end
      end

      def properties
        @properties ||= value.fetch('properties') { {} }
      end

      def properties_schemas
        @properties_schemas ||= Hash.new do |hash, key|
          if properties.key?(key)
            subschema(properties.fetch(key), "properties/#{key}")
          end
        end
      end

      def pattern_properties
        @pattern_properties ||= value.fetch('patternProperties') { {} }.map do |pattern, property_schema|
          [ecma_262_regex(pattern), subschema(property_schema, "patternProperties/#{pattern}")]
        end
      end

      def additional_properties_schema
        @additional_properties_schema ||= if value.key?('additionalProperties')
          subschema(value.fetch('additionalProperties'), 'additionalProperties')
        end
      end
    end
  end
end
