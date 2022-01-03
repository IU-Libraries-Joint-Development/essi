module ESSI
  module SourceIdentifierMetadata
    extend ActiveSupport::Concern

    included do
      property :source_identifier,
               predicate: 'http://purl.org/dc/terms/identifier',
               multiple: true do |index|
                 index.as :stored_searchable, :facetable
               end
    end
  end
end
