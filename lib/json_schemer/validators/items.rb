# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Items < Schema
      def validate(instance, instance_location)
        return output(instance, instance_location, true) unless instance.is_a?(Array)

        output(instance, instance_location, :all?) do |yielder|
          instance.each_with_index do |item, index|
            if !value.is_a?(Array)
              yielder << super(item, "#{instance_location}/#{index}")
            elsif index < value.size
              yielder << items_schemas[index].validate(item, "#{instance_location}/#{index}")
            elsif additional_items_schema
              yielder << additional_items_schema.validate(item, "#{instance_location}/#{index}")
            else
              break
            end
          end
        end
      end

    private

      def items_schemas
        @items_schemas ||= Hash.new do |hash, key|
          hash[key] = Schema.new(root, self, value[key], "#{keyword_location}/#{key}", parent_uri)
        end
      end

      def additional_items_schema
        @additional_items_schema ||= if parent.value.key?('additionalItems')
          Schema.new(
            root,
            parent,
            parent.value.fetch('additionalItems'),
            "#{parent.keyword_location}/additionalItems",
            parent_uri
          )
        end
      end
    end
  end
end
