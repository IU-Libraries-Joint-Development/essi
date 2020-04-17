module ESSI
  module IndexesImageMetadata
    # We're overriding a method from IndexBasicMetadata
    def rdf_service
      ESSI::ImageMetadataIndexer
    end
  end
end
