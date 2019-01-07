# frozen_string_literal: true
# fixme: then & else are nested under if in output
module JSONSchemer
  module Validators
    class If < Schema
      def validate(instance, instance_location)
        if_output = super
        if if_output.fetch('valid')
          then_output = then_schema.validate(instance, instance_location)
          validations = Enumerator.new do |yielder|
            if_output.fetch('annotations').each { |annotation| yielder << annotation }
            yielder << then_output
          end
          output(instance, instance_location, then_output.fetch('valid'), validations)
        else
          else_output = else_schema.validate(instance, instance_location)
          validations = Enumerator.new do |yielder|
            if_output.fetch('errors').each { |annotation| yielder << annotation }
            yielder << else_output
          end
          output(instance, instance_location, else_output.fetch('valid'), validations)
        end
      end

    private

      def then_schema
        Schema.new(root, parent, parent.value['then'], "#{parent.keyword_location}/then", parent_uri)
      end

      def else_schema
        Schema.new(root, parent, parent.value['else'], "#{parent.keyword_location}/else", parent_uri)
      end
    end
  end
end
