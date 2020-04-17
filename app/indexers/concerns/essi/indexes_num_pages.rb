# a work type applying this module must have its own indexer to avoid
# impacting Hyrax::BasicMetadataIndexer and impacting other classes
module ESSI
  module IndexesNumPages
    extend ActiveSupport::Concern

    included do
      self.new(nil).rdf_service.class_eval do
        self.stored_and_facetable_fields += %i[num_pages]
      end
    end
  end
end
