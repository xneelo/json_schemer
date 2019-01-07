# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Ref < Validator
      NET_HTTP_REF_RESOLVER = proc { |uri| JSON.parse(Net::HTTP.get(uri)) }
      JSON_POINTER_REGEX_STRING = '(\/([^~\/]|~[01])*)*'
      JSON_POINTER_REGEX = /\A#{JSON_POINTER_REGEX_STRING}\z/.freeze
      RELATIVE_JSON_POINTER_REGEX = /\A(0|[1-9]\d*)(#|#{JSON_POINTER_REGEX_STRING})?\z/.freeze

      def validate(instance, instance_location)
        validate_children(instance, instance_location, :all?)
      end

    private

      def children
        ref_uri = join_uri(parent_uri, value)

        if valid_json_pointer?(ref_uri.fragment)
          ref_pointer = Hana::Pointer.new(URI.decode_www_form_component(ref_uri.fragment))
          if value.start_with?('#')
            yield Schema.new(root, self, ref_pointer.eval(root.value), ref_uri.fragment, pointer_uri(root.value, ref_pointer))
          else
            ref_root_value = NET_HTTP_REF_RESOLVER.call(ref_uri)
            ref_root = Schema.new(nil, self, ref_root_value, ref_uri.fragment, ref_uri.to_s)
            ref_root.root = ref_root
            yield Schema.new(ref_root, ref_root, ref_pointer.eval(ref_root_value), ref_uri.fragment, pointer_uri(ref_root_value, ref_pointer))
          end
        elsif id = root.ids[ref_uri.to_s]
          yield Schema.new(root, self, id.fetch(:schema), id.fetch(:pointer), ref_uri)
        else
          ref_root_value = NET_HTTP_REF_RESOLVER.call(ref_uri)
          ref_root = Schema.new(nil, self, ref_root_value, nil, nil)
          ref_root.root = ref_root
          id = ref_root.ids[ref_uri.to_s] || { schema: ref_root_value, pointer: '' }
          yield Schema.new(ref_root, ref_root, id.fetch(:schema), id.fetch(:pointer), ref_uri)
        end
      end

      def valid_json_pointer?(data)
        !!(JSON_POINTER_REGEX =~ data)
      end
    end
  end
end
