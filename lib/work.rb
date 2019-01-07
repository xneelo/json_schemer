# frozen_string_literal: true

require 'json'
require 'uri'
require 'time'
require 'base64'
require 'pathname'
require 'net/http'
require 'hana'
require 'ipaddr'
require 'uri_template'
require 'regexp_parser'
require 'ecma-re-validator'

# generic
require_relative 'json_schemer/validators/validator'
require_relative 'json_schemer/validators/schema'
require_relative 'json_schemer/validators/all_of'
require_relative 'json_schemer/validators/any_of'
require_relative 'json_schemer/validators/one_of'
require_relative 'json_schemer/validators/const'
require_relative 'json_schemer/validators/enum'
require_relative 'json_schemer/validators/if'
require_relative 'json_schemer/validators/not'
require_relative 'json_schemer/validators/type'
require_relative 'json_schemer/validators/ref'

# number
require_relative 'json_schemer/validators/multiple_of'
require_relative 'json_schemer/validators/maximum'
require_relative 'json_schemer/validators/exclusive_maximum'
require_relative 'json_schemer/validators/minimum'
require_relative 'json_schemer/validators/exclusive_minimum'

# string
require_relative 'json_schemer/validators/max_length'
require_relative 'json_schemer/validators/min_length'
require_relative 'json_schemer/validators/pattern'
require_relative 'json_schemer/validators/format'
require_relative 'json_schemer/validators/content'

# array
require_relative 'json_schemer/validators/max_items'
require_relative 'json_schemer/validators/min_items'
require_relative 'json_schemer/validators/items'
require_relative 'json_schemer/validators/unique_items'
require_relative 'json_schemer/validators/contains'

# object
require_relative 'json_schemer/validators/max_properties'
require_relative 'json_schemer/validators/min_properties'
require_relative 'json_schemer/validators/required'
require_relative 'json_schemer/validators/properties'
require_relative 'json_schemer/validators/dependencies'

def schema(value)
  JSONSchemer::Validators::Schema.new(nil, nil, value, '#', nil).tap do |schema|
    schema.root = schema
  end
end

def resolve(output)
  output = output.dup
  %w[annotations errors].each do |key|
    output[key] = output.fetch(key).map { |x| resolve(x) } if output[key]
  end
  output
end

def pretty(output)
  JSON.pretty_generate(resolve(output))
end

Dir["JSON-Schema-Test-Suite/tests/draft7/**/*.json"].each do |file|
  JSON.parse(File.read(file)).each_with_index do |defn, defn_index|
    defn.fetch('tests').each_with_index do |test, test_index|
      schema = schema(defn.fetch('schema'))
      if schema.valid?(test.fetch('data'), '#') != test.fetch('valid')
        puts "error: #{file}:#{defn_index}:#{test_index}"
      end
    end
  end
end

binding.irb
