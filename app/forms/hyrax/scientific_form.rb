# Generated via
#  `rails generate hyrax:work Scientific`
module Hyrax
  # Generated form for Scientific
  class ScientificForm < Hyrax::Forms::WorkForm
    self.model_class = ::Scientific
    self.terms += [:resource_type]
    self.required_fields -= [:keyword]
    include ESSI::ScientificFormBehavior
  end
end
