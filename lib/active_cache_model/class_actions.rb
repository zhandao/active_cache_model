require 'multi_json'

module ActiveCacheModel
  module ClassActions
    def has_attr name, type = 'string', enum: nil, defaults_to: nil, **validate
      attr_accessor name
      validates! name, **validate if validate.present?
      schema[name] = { type: type.to_s.underscore, enum: enum, default_val: defaults_to }
    end

    %w[integer float string date_time date time boolean decimal timestamp].each do |type|
      define_method type do |name, **args|
        has_attr name, type, **args
      end
    end

    def primary_key name = :id, *args
      if name == :id
        store("#{cls_name}/next_id", 1)
        integer :id, defaults_to: -> { fetch_id_and_inc }
      else
        config.primary_key = name
        has_attr name, *args
      end
    end

    def create(attrs)
      new(attrs).tap { |obj| obj.save }
    end

    def find(key)
      result = fetch!("#{name.underscore}/#{key}")
      result = MultiJson.load(result).symbolize_keys.map do |attr, value|
        value = type_convert(attr, value)
        value = schema[attr][:enum][value] if schema[attr][:enum].present?

        [attr, value]
      end.to_h

      new(result)
    end

    def find_by(condition)
      # TODO
    end

    def where(condition)
      # TODO
    end
  end
end
