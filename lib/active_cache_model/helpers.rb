require 'active_cache_model/error'

module ActiveCacheModel
  module Helpers
    def self.included(kclass)
      kclass.class_eval do
        class << self
          def store(key, value, options = { })
            key = "#{self.name.underscore}/#{key}"
            config.handler.write(key, value, {
                expires_in: config.auto_destroy_in,
                race_condition_ttl: 5.seconds
            }.merge(options))
          end

          def push(value, to:, process: :itself, **options)
            arr = (fetch(to) || [ ]) << value
            store(to, arr.send(process), options)
            arr
          end

          def arr_remove(value, from:, **options)
            arr = fetch(from) || [ ]
            arr.delete(value)
            store(from, arr, options)
            arr
          end

          def fetch(key, *args)
            key = "#{self.name.underscore}/#{key}"
            config.handler.read(key, *args)
          end

          def fetch!(key, *args)
            fetch(key, *args) or raise Error, "cannot fetch #{args.first}"
          end

          def pull(*keys)
            config.handler.read_multi(*(keys.map { |key| "#{self.name.underscore}/#{key}" })) || { }
          end

          def delete(key)
            key = "#{self.name.underscore}/#{key}"
            config.handler.delete(key)
          end

          def load_hash(hash)
            hash.symbolize_keys.map do |attr, value|
              value = type_convert(attr, value)
              value = schema[attr][:enum][value] if schema[attr][:enum].present? && value.present?

              [attr, value]
            end.to_h
          end

          private

          def type_convert(attr_name, attr_val)
            case schema[attr_name][:type]
              when 'date_time'; attr_val&.to_datetime
              when 'date';      attr_val&.to_date
              when 'time';      attr_val&.to_time
              when 'integer';   attr_val&.to_i
              when 'float';     attr_val&.to_f
              when 'boolean';   attr_val.in?([true, 1, 'true']) ? true : false
              else attr_val
            end
          end
        end # end of class methods

        private

        def fetch_id_and_inc
          id = (fetch('next_id') || 1).to_i
          store('next_id', id + 1)
          id
        end

        def index_store
          return unless indices.present? && config.enable_query
          indices.each do |index_name|
            # e.g. { 'ns/indices/email/x@skippingcat.com' => [123, 234, 345] }
            push(primary_value, to: "indices/#{index_name}/#{send(index_name)}", expires_in: nil)
            push(send(index_name), to: "indices/#{index_name}", process: :uniq, expires_in: nil)
          end
        end

        def index_remove
          return unless indices.present? && config.enable_query
          indices.each do |index_name|
            arr_remove(primary_value, from: "indices/#{index_name}/#{send(index_name)}", expires_in: nil)
          end
        end
      end
    end
  end
end
