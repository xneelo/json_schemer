# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Schema < Validator
      class << self
        def validators
          @validators ||= {
            # generic
            'const' => Const,
            'enum' => Enum,
            'if' => If,
            'not' => Not,
            'allOf' => AllOf,
            'anyOf' => AnyOf,
            'oneOf' => OneOf,
            'type' => Type,

            # number
            'maximum' => Maximum,
            'minimum' => Minimum,
            'exclusiveMaximum' => ExclusiveMaximum,
            'exclusiveMinimum' => ExclusiveMinimum,
            'multipleOf' => MultipleOf,

            # string
            'maxLength' => MaxLength,
            'minLength' => MinLength,
            'pattern' => Pattern,
            'format' => Format,

            # array
            'maxItems' => MaxItems,
            'minItems' => MinItems,
            'items' => Items,
            'uniqueItems' => UniqueItems,
            'contains' => Contains,

            # object
            'maxProperties' => MaxProperties,
            'minProperties' => MinProperties,
            'required' => Required,
            'dependencies' => Dependencies
          }.freeze
        end
      end

      def initialize(*)
        super
        if value.is_a?(Hash)
          self.parent_uri = join_uri(parent_uri, value[id_keyword])
        end
      end

      def valid?(instance, instance_location)
        validate(instance, instance_location).fetch('valid')
      end

      def validate(instance, instance_location)
        if value == true || value == false || value.nil? || value.empty?
          valid = value.nil? || (value.is_a?(Hash) && value.empty?) || value
          return output(instance, instance_location, valid)
        end
        validate_children(instance, instance_location, :all?)
      end

      def ids
        @ids ||= resolve_ids(value)
      end

    private

      def children
        if value.key?('$ref')
          yield Ref.new(root, self, value.fetch('$ref'), "#{keyword_location}/$ref", parent_uri)
          return
        end

        if value.key?('properties') || value.key?('patternProperties') || value.key?('additionalProperties') || value.key?('propertyNames')
          yield Properties.new(root, self, value, keyword_location, parent_uri)
        end

        if value.key?('contentEncoding') || value.key?('contentMediaType')
          yield Content.new(root, self, value, keyword_location, parent_uri)
        end

        value.each do |key, val|
          next unless klass = self.class.validators[key]
          yield klass.new(root, self, val, "#{keyword_location}/#{key}", parent_uri)
        end
      end

      def resolve_ids(schema, ids = {}, parent_uri = nil, pointer = '')
        if schema.is_a?(Array)
          schema.each_with_index { |subschema, index| resolve_ids(subschema, ids, parent_uri, "#{pointer}/#{index}") }
        elsif schema.is_a?(Hash)
          id = schema[id_keyword]
          uri = join_uri(parent_uri, id)
          unless uri == parent_uri
            ids[uri.to_s] = {
              schema: schema,
              pointer: pointer
            }
          end
          if definitions = schema['definitions']
            definitions.each { |key, subschema| resolve_ids(subschema, ids, uri, "#{pointer}/definitions/#{key}") }
          end
        end
        ids
      end
    end
  end
end
