# new method to ensure work type is set, to ensure allinson_flex properties are loaded
module Extensions
  module Bulkrax
    module CsvEntry
      module AddWorkType
        def add_record_metadata(required_fields: [], excluded_fields: [])
          raise StandardError, 'Record not found' if record.nil?
          self.parsed_metadata ||= {}
          record.each do |key, value|
            next if key.in?(excluded_fields)
            next unless key.in?(required_fields) || required_fields.none?

            index = key[/\d+/].to_i - 1 if key[/\d+/].to_i != 0
            add_metadata(key_without_numbers(key), value, index)
          end
          self.parsed_metadata
        end

        def add_work_type
          add_record_metadata(required_fields: ['model'])
        end

        def add_standard_metadata
          add_record_metadata(excluded_fields: ['file', 'collection'])
        end

        # modified from bulkrax to ensure setting model before adding other metadata
        def build_metadata
          raise StandardError, 'Record not found' if record.nil?
          raise StandardError, "Missing required elements, missing element(s) are: #{importerexporter.parser.missing_elements(keys_without_numbers(record.keys)).join(', ')}" unless importerexporter.parser.required_elements?(keys_without_numbers(record.keys))
    
          self.parsed_metadata = {}
          self.parsed_metadata[work_identifier] = [record[source_identifier]]
          add_work_type
          add_standard_metadata
          add_file
          add_visibility
          add_rights_statement
          add_admin_set_id
          add_collections
          add_local
          self.parsed_metadata
        end
      end
    end
  end
end
