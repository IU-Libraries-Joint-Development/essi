# Generated via
#  `rails generate hyrax:work BibRecord`
module Hyrax
  # Generated form for BibRecord
  class BibRecordForm < Hyrax::Forms::WorkForm
    self.model_class = ::BibRecord
    self.terms += [:resource_type, :source_metadata_identifier, :series]
    self.required_fields -= [:title, :creator, :keyword]
    self.primary_fields = [:title, :creator, :rights_statement, :source_metadata_identifier]
    include ESSI::BibRecordFormBehavior
  end
end
