module Extensions
  module Bulkrax
    module Entry
      module AllinsonFlexFields
        def build_metadata
          # Ensure loading of all flexible metadata properties for the imported work type
          super
          factory_class&.new
          self.parsed_metadata
        end
      end
    end
  end
end
