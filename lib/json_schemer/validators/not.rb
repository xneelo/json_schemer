# frozen_string_literal: true
module JSONSchemer
  module Validators
    class Not < Schema
      def validate(instance, instance_location)
        output = super
        valid = output.fetch('valid')
        output['valid'] = !valid
        output['errors'] = output.delete('annotations') if valid
        output['annotations'] = output.delete('errors') unless valid
        output
      end
    end
  end
end
