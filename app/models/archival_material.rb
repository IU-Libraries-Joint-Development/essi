# Generated via
#  `rails generate hyrax:work ArchivalMaterial`
class ArchivalMaterial < ActiveFedora::Base
  include ESSI::ArchivalMaterialBehavior
  include ::Hyrax::WorkBehavior
  include StructuralMetadata
  include ExtraLockable
  include ESSI::NumPagesBehavior
  include ESSI::OCRBehavior
  include ESSI::PDFBehavior
  include ESSI::PDFDefaultDownloadable

  self.indexer = ArchivalMaterialIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # Include properties for remote metadata lookup
  include ESSI::RemoteLookupMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)

  include AllinsonFlex::DynamicMetadataBehavior
  include ESSI::DynamicMetadataBehavior
  include ::Hyrax::BasicMetadata
end
