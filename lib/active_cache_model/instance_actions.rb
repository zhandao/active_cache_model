require 'active_cache_model/attr_processing'

module ActiveCacheModel
  module InstanceActions
    include AttrProcessing

    def initialize(attrs)
      raise StandardError, 'Please set `primary_key`' unless defined?(config.primary_key)

      run_callbacks :initialize do
        run_callbacks :create do
          super(@default_attrs.merge(created_at: Time.current, **attrs))
        end
      end
    end

    def cache_key
      return @cache_key if @cache_key

      key = send(config.primary_key)
      @cache_key = "#{cls_name}/#{key}"
    end

    def save
      run_callbacks :save do
        self.valid?
        store(cache_key, self.as_json.map(&attr_processing).to_h.to_json)
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
        config.handler.delete(cache_key)
      end
    end

    def attributes
      schema.keys.map { |k| [k, nil] }.to_h
    end

    def inspect
      [self.class.name, ' ', self.as_json.to_s, ' is cached by key: ', cache_key].join
    end

    def to_s; self.as_json.to_s end
  end
end
