# modified from bulkrax 5.5.1
module Extensions
  module Bulkrax
    module Entry
      module MultipleCheck
        # modified to remove hard assertion that rights_statement is necessarily multi-valued
        def multiple?(field)
          @multiple_bulkrax_fields ||=
            %W[
              file
              remote_files
              #{related_parents_parsed_mapping}
              #{related_children_parsed_mapping}
            ]
            
          return true if @multiple_bulkrax_fields.include?(field)
          return false if field == 'model'
              
          field_supported?(field) && factory_class&.properties&.[](field)&.[]('multiple')
        end
      end
    end
  end
end
