require 'active_cache_model/version'
require 'active_cache_model/config'
require 'active_cache_model/class_actions'
require 'active_cache_model/instance_actions'
require 'active_cache_model/index'
require 'active_cache_model/helpers'

# https://ruby-china.github.io/rails-guides/active_model_basics.html
module ActiveCacheModel
  class Base
    def self.inherited(kclass)
      kclass.class_eval do
        extend ActiveModel::Callbacks

        include ActiveModel::Validations
        include ActiveModel::Model
        include ActiveModel::Serializers::JSON

        include Helpers
        extend  ClassActions
        include InstanceActions

        delegate :store, :delete, :push, :arr_remove,
                 :fetch, :fetch!, :read_multi,
                 to: self

        extend Index

        cattr_accessor(:config)  { Config.new }
        cattr_accessor(:schema)  { Hash.new }
        cattr_accessor(:indices) { Array.new }
        cattr_accessor :last

        delegate :config, :schema, :indices, to: self

        # default attributes
        date_time :created_at
        date_time :updated_at

        define_model_callbacks :init, :save, :create, :update, :destroy

        before_init   { set_default_attrs }
        before_save   { self.updated_at = Time.current }

        after_create  { index_store }
        after_create  { self.class.last = self }

        after_destroy { index_remove }
      end
    end
  end
end
