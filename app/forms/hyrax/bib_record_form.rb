# Generated via
#  `rails generate hyrax:work BibRecord`
module Hyrax
  # Generated form for BibRecord
  class BibRecordForm < Hyrax::Forms::WorkForm
    self.model_class = ::BibRecord
    self.terms += [:resource_type, :source_metadata_identifier, :series]
    self.required_fields -= [:keyword]
    include ESSI::BibRecordFormBehavior
  end
end
