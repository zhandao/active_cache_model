require 'active_cache_model/error'

module ActiveCacheModel
  module AttrProcessing
    def set_default_attrs
      @default_attrs = schema.map do |attr_name, attr_schema|
        { attr_name => default_val(attr_schema[:default_val]) }
      end.reduce({ created_at: Time.current }, :merge)
    end

    def attr_processing
      proc do |attr_name, attr_val|
        s = schema[attr_name]
        attr_val = default_val(s[:default_val]) if attr_val.nil? && !s[:default_val].nil?
        attr_val = enum(s[:enum], attr_val) if s[:enum]
        [attr_name, attr_val]
      end
    end

    def default_val(schema)
      return nil if schema.nil?
      schema.is_a?(Proc) ? instance_exec(&schema) : schema
    end

    def enum(schema, value)
      if schema.is_a?(Hash) && !schema.symbolize_keys.key?(value.to_sym)
        schema.keys[schema.values.index(value)]
      elsif schema.is_a?(Array) && !value.in?(0..schema.size-1)
        schema.index(value) or raise
      else
        value
      end
    rescue
      raise Error, 'enum validation fails'
    end
  end
end
