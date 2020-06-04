# Generated via
#  `rails generate hyrax:work PagedResource`
module Hyrax
  # Generated form for PagedResource
  class PagedResourceForm < Hyrax::Forms::WorkForm
    self.model_class = ::PagedResource
    self.terms += [:resource_type, :series, :pdf_type]
    self.required_fields -= [:title, :creator, :keyword]
    self.primary_fields = [:title, :creator, :rights_statement]
    include ESSI::PagedResourceFormBehavior
    include ESSI::OCRTerms
    include ESSI::RemoteMetadataFormElements

    def pdf_type
      if self["pdf_type"].blank?
        "gray"
      else
        self["pdf_type"]
      end
    end

  end
end
