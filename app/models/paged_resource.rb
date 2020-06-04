# Generated via
#  `rails generate hyrax:work PagedResource`
class PagedResource < ActiveFedora::Base
  include ESSI::PagedResourceBehavior
  include ::Hyrax::WorkBehavior
  include StructuralMetadata
  include ExtraLockable
  include ESSI::NumPagesMetadata
  include ESSI::NumPagesBehavior
  include ESSI::OCRBehavior
  include ESSI::OCRMetadata

  self.indexer = PagedResourceIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :pdf_type, predicate: ::RDF::URI.intern('https://lib.my.edu/terms/pdfType'), multiple: false do |index|
    index.as :stored_searchable
  end


 # Include extended metadata common to most Work Types
  include ESSI::ExtendedMetadata

  # This model includes metadata properties specific to the PagedResource Work Type
  include ESSI::PagedResourceMetadata

  # Include properties for remote metadata lookup
  include ESSI::RemoteLookupMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
