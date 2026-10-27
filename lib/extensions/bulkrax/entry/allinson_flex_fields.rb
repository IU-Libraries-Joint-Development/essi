# written as an Entry module, but needs to be applied to a specific subclass (e.g. CsvEntry)
module Extensions
  module Bulkrax
    module Entry
      module AllinsonFlexFields
        def establish_factory_class
          result = super
          # Ensure loading of all flexible metadata properties for the imported work type
          factory_class&.new
          result
        end
      end
    end
  end
end
