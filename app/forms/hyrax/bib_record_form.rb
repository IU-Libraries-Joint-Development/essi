# Generated via
#  `rails generate hyrax:work BibRecord`
module Hyrax
  # Generated form for BibRecord
  class BibRecordForm < Hyrax::Forms::WorkForm
    self.model_class = ::BibRecord
    self.terms += [:resource_type, :source_metadata_identifier]
    self.required_fields -= [:keyword]
    self.required_fields += [:source_metadata_identifier]
    include ESSI::BibRecordFormBehavior
  end
end
