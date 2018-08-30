require 'active_cache_model/attr_processing'
require 'active_cache_model/error'

module ActiveCacheModel
  module InstanceActions
    include AttrProcessing

    def initialize(attrs)
      raise Error, 'Please set `primary_key`' unless defined?(config.primary_key)

      run_callbacks :init do
        super(@default_attrs.merge(created_at: Time.current, **attrs))
      end
    end

    def primary_value
      send(config.primary_key)
    end

    def save
      run_callbacks :save do
        self.valid?
        store(primary_value, self.as_json.map(&attr_processing).to_h)
      end
    end

    def update(attrs)
      run_callbacks :update do
        attrs.except(config.primary_key).each do |key, value|
          self.send("#{key}=", value)
        end.present? and save
      end
    end

    def destroy
      run_callbacks :destroy do
        delete(primary_value)
      end
    end

    def attributes
      schema.keys.map { |k| [k, nil] }.to_h
    end

    def inspect
      [self.class.name, ' ', self.as_json.to_s, ' is cached by key: ', "#{self.class.name.underscore}/#{primary_value}"].join
    end

    def to_s; self.as_json.to_s end
  end
end
