module ESSI
  module FileSetMetadata
    extend ActiveSupport::Concern

    included do
      # Add properties appropriate for use in file set objects
      property :viewing_hint, predicate: ::RDF::Vocab::IIIF.viewingHint, multiple: false do |index|
        index.as :stored_searchable
      end

      property :content_location, predicate: ::RDF::Vocab::IANA.service, multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end
