# frozen_string_literal: true
# fixme: extra error/annotation level
module JSONSchemer
  module Validators
    class ContentEncoding < Validator
      def decode(instance)
        case value.downcase
        when 'base64'
          safe_strict_decode64(instance)
        else # '7bit', '8bit', 'binary', 'quoted-printable'
          raise NotImplementedError
        end
      end

      def valid?(instance, instance_location)
        !!instance
      end

    private

      def safe_strict_decode64(data)
        begin
          Base64.strict_decode64(data)
        rescue ArgumentError => e
          raise e unless e.message == 'invalid base64'
          nil
        end
      end
    end

    class ContentMediaType < Validator
      def valid?(instance, instance_location)
        case value.downcase
        when 'application/json'
          valid_json?(instance)
        else
          raise NotImplementedError
        end
      end

    private

      def valid_json?(instance)
        JSON.parse(instance)
        true
      rescue JSON::ParserError
        false
      end
    end

    class Content < Validator
      def validate(instance, instance_location)
        return output(instance, instance_location, true) unless instance.is_a?(String)

        output(instance, instance_location, :all?) do |yielder|
          decoded_instance = instance

          if content_encoding
            decoded_instance = content_encoding.decode(instance)
            yielder << content_encoding.validate(decoded_instance, instance_location)
          end

          if content_media_type && decoded_instance
            yielder << content_media_type.validate(decoded_instance, instance_location)
          end
        end
      end

    private

      def content_encoding
        @content_encoding ||= if value.key?('contentEncoding')
          ContentEncoding.new(root, self, value.fetch('contentEncoding'), "#{keyword_location}/contentEncoding", parent_uri)
        end
      end

      def content_media_type
        @content_media_type ||= if value.key?('contentMediaType')
          ContentMediaType.new(root, self, value.fetch('contentMediaType'), "#{keyword_location}/contentMediaType", parent_uri)
        end
      end
    end
  end
end
