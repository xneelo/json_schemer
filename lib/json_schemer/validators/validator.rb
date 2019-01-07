# frozen_string_literal: true
module JSONSchemer
  module Validators
    Validator = Struct.new(:root, :parent, :value, :keyword_location, :parent_uri) do
      RUBY_REGEX_ANCHORS_TO_ECMA_262 = {
        :bos => 'A',
        :eos => 'z',
        :bol => '\A',
        :eol => '\z'
      }.freeze

      def valid?(instance, instance_location)
        raise NotImplementedError
      end

      def validate(instance, instance_location)
        output(instance, instance_location, valid?(instance, instance_location))
      end

    private

      def children
        raise NotImplementedError
      end

      def validate_children(instance, instance_location, predicate)
        output(instance, instance_location, predicate) do |yielder|
          children { |child| yielder << child.validate(instance, instance_location) }
        end
      end

      def output(instance, instance_location, valid_or_predicate, children = nil)
        unit = {
          'keywordLocation' => keyword_location,
          'instanceLocation' => instance_location
        }
        children ||= Enumerator.new(&Proc.new) if block_given?
        valid = unit['valid'] = if valid_or_predicate.is_a?(Symbol)
          children.public_send(valid_or_predicate) { |child| child.fetch('valid') }
        else
          valid_or_predicate
        end
        unit[valid ? 'annotations' : 'errors'] = children if children
        unit
      end

      def subschema(schema, location)
        Schema.new(root, self, schema, "#{keyword_location}/#{location}", parent_uri)
      end

      def id_keyword
        '$id'
      end

      def join_uri(a, b)
        if a && b
          URI.join(a, b)
        elsif b
          URI.parse(b)
        else
          a
        end
      end

      def pointer_uri(schema, pointer)
        uri_parts = nil
        pointer.reduce(schema) do |obj, token|
          next obj.fetch(token.to_i) if obj.is_a?(Array)
          if obj_id = obj[id_keyword]
            uri_parts ||= []
            uri_parts << obj_id
          end
          obj.fetch(token)
        end
        uri_parts ? URI.join(*uri_parts) : nil
      end

      def ecma_262_regex(pattern)
        @ecma_262_regex ||= {}
        @ecma_262_regex[pattern] ||= Regexp.new(
          Regexp::Scanner.scan(pattern).map do |type, token, text|
            type == :anchor ? RUBY_REGEX_ANCHORS_TO_ECMA_262.fetch(token, text) : text
          end.join
        )
      end
    end
  end
end
