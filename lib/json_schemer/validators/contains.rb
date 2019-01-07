# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Contains < Schema
      def validate(instance, instance_location)
        return output(instance, instance_location, true) unless instance.is_a?(Array)

        output(instance, instance_location, :any?) do |yielder|
          instance.each_with_index do |item, index|
            yielder << super(item, "#{instance_location}/#{index}")
          end
        end
      end
    end
  end
end
