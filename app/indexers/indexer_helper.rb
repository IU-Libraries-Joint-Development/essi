module IndexerHelper

 def self.iiif_index_strategy
   ESSI.config.dig(:essi, :iiif_index_strategy) || \
   CatalogController.blacklight_config.iiif_search[:iiif_index_strategy]
 end
end