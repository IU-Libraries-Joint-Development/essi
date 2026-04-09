# Generated via
#  `rails generate hyrax:work BibRecord`
module Hyrax
  class BibRecordPresenter < Hyrax::WorkShowPresenter
    include ESSI::PresentsDelegatedAttributes
    include ESSI::PresentsOCR
    include ESSI::PresentsStructure
    delegate :series, to: :solr_document
    include AllinsonFlex::DynamicPresenterBehavior
    include ESSI::OptimizedAdminSetLookup
    self.model_class = ::BibRecord
    include ESSI::PresentsCustomRenderedAttributes
    delegate(*delegated_properties, to: :solr_document)
  end
end
