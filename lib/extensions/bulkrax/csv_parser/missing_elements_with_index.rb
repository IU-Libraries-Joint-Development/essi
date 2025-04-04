# modified from bulkrax 5.5.1
module Extensions
  module Bulkrax
    module CsvParser
      module MissingElementsWithIndex
        def missing_elements(record)
          keys_from_record = keys_without_numbers(record.reject { |_, v| v.blank? }.keys.compact.uniq.map(&:to_s))
          keys = []
          # Because we're persisting the mapping in the database, these are likely string keys.
          # However, there's no guarantee.  So, we need to ensure that by running stringify.
          importerexporter.mapping.stringify_keys.map do |k, v|
            ::Array.wrap(v['from']).each do |vf|
              # below line modified to allow title_1 (from an export CSV) to pass for title
              keys << unindex(k) if keys_from_record.include?(unindex(vf))
            end
          end
          required_elements.map(&:to_s) - keys.uniq.map(&:to_s)
        end

        def unindex(key)
          key.sub(/_1$/, '')
        end
      end
    end
  end
end
