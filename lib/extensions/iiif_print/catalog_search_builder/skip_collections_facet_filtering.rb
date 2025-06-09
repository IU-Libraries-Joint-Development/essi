module Extensions
  module IiifPrint
    module CatalogSearchBuilder
      module SkipCollectionsFacetFiltering
        def self.included(base)
          base.class_eval do
            self.default_processor_chain -= [:filter_collection_facet_for_access]
          end
        end
      end
    end
  end
end
