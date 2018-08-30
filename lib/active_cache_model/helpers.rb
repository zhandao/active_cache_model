require 'active_cache_model/error'

module ActiveCacheModel
  module Helpers
    def self.included(kclass)
      kclass.class_eval do
        class << self
          def store(name, value, options = { })
            config.handler.write(name, value,
                                 { expires_in: config.auto_destroy_in }.merge(options))
          end

          def fetch(*args)
            config.handler.read(*args)
          end

          def fetch!(*args)
            fetch(*args) or raise Error, "cannot fetch #{args.first}"
          end

          def read_multi(*names)
            config.handler.read_multi(*names)
          end

          def store_keys
            return [ ] unless config.enable_query
            fetch("#{name.underscore}/store_keys") | [ ]
          end

          # TODO
          def store_keys_add(key)
            return false unless config.enable_query
            keys = fetch("#{name.underscore}/store_keys") || [ ] << key
            store("#{name.underscore}/store_keys", keys)
          end

          private

          def type_convert(attr_name, attr_val)
            case schema[attr_name][:type]
              when 'date_time'; attr_val.to_datetime
              when 'date';      attr_val.to_date
              when 'time';      attr_val.to_time
              when 'integer';   attr_val.to_i
              when 'float';     attr_val.to_f
              when 'boolean';   attr_val.in?([true, 1, 'true']) ? true : false
              else attr_val
            end
          end
        end # end of class methods


        def cls_name
          self.class.name.underscore
        end

        private

        def fetch_id_and_inc
          id = (fetch("#{cls_name}/next_id") || 1).to_i
          store("#{cls_name}/next_id", id + 1)
          id
        end
      end
    end
  end
end
