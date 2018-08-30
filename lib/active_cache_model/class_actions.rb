require 'active_cache_model/error'

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
        store('next_id', 1)
        integer :id, defaults_to: -> { fetch_id_and_inc }
      else
        config.primary_key = name
        has_attr name, *args
      end
    end

    def index(name)
      return unless name.in?(schema.keys)
      indices << name
    end

    def create(attrs)
      new(attrs).tap { |obj| obj.run_callbacks(:create) { obj.save } }
    end

    def find(key)
      new(load_hash(fetch!(key)))
    end

    def find_by(condition)
      where(condition).last
    end

    def where(condition)
      raise Error, 'Unable to query!' unless indices.present? && config.enable_query

      main_cond = condition.keys.first
      raise Error, "`#{main_cond}` has not been indexed!" unless indices.include?(main_cond)
      return [ ] unless (index = fetch("indices/#{main_cond}/#{condition[main_cond]}")).is_a?(Array)
      records = pull(*index).values.map { |obj| new(load_hash(obj)) }

      condition.except(main_cond).each do |key, val|
        records.delete_if { |record| record.send(key) != val }
      end
      records
    end
  end
end
