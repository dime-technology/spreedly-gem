# frozen_string_literal: true

module Spreedly
  module Fields
    def self.included(base)
      base.extend ClassMethods
    end

    def initialize_fields(xml_doc)
      self.class.fields.each do |field|
        node = xml_doc.at_xpath(".//#{field}")
        if node
          value = node.inner_html.strip
          instance_variable_set("@#{field}", value)
        end
      end
    end

    def field_hash
      self.class.fields.each_with_object({}) do |each, hash|
        hash[each] = send(each)
      end
    end

    module ClassMethods
      def field(*fields_to_add)
        options = fields_to_add.extract_options!
        @fields ||= []
        fields_to_add.each do |f|
          @fields += [f]
          add_accessor_for(f, options[:type])
        end
      end

      def fields
        @fields ||= []
      end

      def inherited(subclass)
        subclass.instance_variable_set('@fields', instance_variable_get('@fields'))
      end

      def add_accessor_for(f, field_type)
        p '------------- field_type  -------------'
        p "field_type: #{field_type}"
        p "field: #{f}"
        case field_type
        when :boolean
          add_boolean_accessor(f)
        when :date_time
          add_date_time_accessor(f)
        when :integer
          add_integer_accessor(f)
        when nil
          attr_reader f
        else
          raise "Unknown field type '#{options[:type]}' for field '#{f}'"
        end
      end

      def add_boolean_accessor(f)
        define_method(f) do
          return nil unless instance_variable_get("@#{f}")

          instance_variable_get("@#{f}") == 'true'
        end
        alias_method "#{f}?", f
      end

      def add_date_time_accessor(f)
        define_method(f) do
          if instance_variable_get("@#{f}")
            Time.parse(instance_variable_get("@#{f}"))
          end
        end
      end

      def add_integer_accessor(f)
        define_method(f) do
          return nil unless instance_variable_get("@#{f}")

          instance_variable_get("@#{f}").to_i
        end
      end
    end
  end
end

class Array
  def extract_options!
    if last.is_a?(Hash)
      pop
    else
      {}
    end
  end
end
