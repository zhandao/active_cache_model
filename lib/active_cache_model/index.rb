module ActiveCacheModel
  module Index
    def reorganize_indices
      indices.each do |index_name|
        (fetch("indices/#{index_name}") || [ ]).each do |index_val|
          index = fetch("indices/#{index_name}/#{index_val}")
          next unless index.is_a?(Array)

          index.map! do |primary_val|
            fetch(primary_val) ? primary_val : nil
          end.compact!

          if index.present?
            store("indices/#{index_name}/#{index_val}", index)
          else
            delete("indices/#{index_name}/#{index_val}")
            arr_remove(index_val, from: "indices/#{index_name}", process: :uniq, expires_in: nil)
          end
        end
      end
    end
  end
end
