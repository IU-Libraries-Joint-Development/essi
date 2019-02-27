module ESSI
  class PagedResourceMetadataIndexer < Hyrax::DeepIndexingService
    self.stored_and_facetable_fields += %i[date_created num_pages publication_place]
    self.stored_fields += %i[viewing_direction viewing_hint]
    self.stored_fields.delete :date_created
  end
end
