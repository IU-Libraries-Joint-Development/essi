module ESSI
  module IndexesBibRecordMetadata
    # We're overriding a method from IndexBasicMetadata
    def rdf_service
      ESSI::BibRecordMetadataIndexer
    end
  end
end
