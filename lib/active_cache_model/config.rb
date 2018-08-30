module ActiveCacheModel
  class Config
    attr_accessor :primary_key, :handler, :auto_destroy_in, :enable_query

    def initialize
      self.primary_key = :id
      self.handler = Rails.cache
      self.enable_query = false
    end
  end
end
