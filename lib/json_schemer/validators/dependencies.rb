# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Dependencies < Validator
      def validate(instance, instance_location)
        return output(instance, instance_location, true) unless instance.is_a?(Hash)

        output(instance, instance_location, :all?) do |yielder|
          value.each_key do |key|
            next unless instance.key?(key)
            yielder << dependency_schemas[key].validate(instance, instance_location)
          end
        end
      end

    private

      def dependency_schemas
        @dependency_schemas ||= Hash.new do |hash, key|
          dependency = value.fetch(key)
          hash[key] = if dependency.is_a?(Array)
            Required.new(root, self, dependency, "#{keyword_location}/#{key}", parent_uri)
          else
            subschema(dependency, key)
          end
        end
      end
    end
  end
end
