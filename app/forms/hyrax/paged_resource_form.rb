# Generated via
#  `rails generate hyrax:work PagedResource`
module Hyrax
  # Generated form for PagedResource
  class PagedResourceForm < Hyrax::Forms::WorkForm
    self.model_class = ::PagedResource
    self.terms += [:resource_type, :source_metadata_identifier]
    self.required_fields -= [:keyword]
    self.required_fields += [:source_metadata_identifier]
    include ESSI::PagedResourceFormBehavior
  end
end
