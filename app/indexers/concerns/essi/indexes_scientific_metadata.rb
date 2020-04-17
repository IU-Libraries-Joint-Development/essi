module ESSI
  module IndexesScientificMetadata
    # We're overriding a method from IndexBasicMetadata
    def rdf_service
      ESSI::ScientificMetadataIndexer
    end
  end
end
