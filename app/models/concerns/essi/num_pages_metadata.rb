module ESSI
  module NumPagesMetadata
    extend ActiveSupport::Concern
    included do
      property :num_pages, predicate: ::RDF::Vocab::BIBO.numPages, multiple: false
    end
  end
end
