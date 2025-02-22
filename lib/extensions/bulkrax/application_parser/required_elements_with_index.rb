# modified from bulkrax 5.5.1
module Extensions
  module Bulkrax
    module ApplicationParser
      module RequiredElementsWithIndex
        # @return [Array<String>]
        def required_elements
          # below line modified to allow title_1 (from an export CSV) to pass for title
          matched_elements = ((importerexporter.mapping.keys.map { |key| unindex(key) } || []) & (::Bulkrax.required_elements || []))
          unless matched_elements.count == ::Bulkrax.required_elements.count
            missing_elements = ::Bulkrax.required_elements - matched_elements
            error_alert = "Missing mapping for at least one required element, missing mappings are: #{missing_elements.join(', ')}"
            raise ::StandardError, error_alert
          end
          if ::Bulkrax.fill_in_blank_source_identifiers
            ::Bulkrax.required_elements
          else
            ::Bulkrax.required_elements + [source_identifier]
          end   
        end

        def unindex(key)
          key.sub(/_1$/, '')
        end
      end
    end
  end
end
