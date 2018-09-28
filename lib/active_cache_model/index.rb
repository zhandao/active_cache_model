module ActiveCacheModel
  module Index
    def reorganize_indices
      indices.each do |index_name|
        (fetch("indices/#{index_name}") || [ ]).each do |index_val|
          indexes = fetch("indices/#{index_name}/#{index_val}")
          next unless indexes.is_a?(Array)

          indexes = pull(*indexes).values.map { |obj| obj[config.primary_key] }
          if indexes.present?
            store("indices/#{index_name}/#{index_val}", indexes)
          else
            delete("indices/#{index_name}/#{index_val}")
            arr_remove(index_val, from: "indices/#{index_name}", process: :uniq, expires_in: nil)
          end
        end
      end
    end
  end
end
