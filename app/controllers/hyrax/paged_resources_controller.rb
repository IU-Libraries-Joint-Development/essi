# Generated via
#  `rails generate hyrax:work PagedResource`
module Hyrax
  # Generated controller for PagedResource
  class PagedResourcesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include ESSI::WorksControllerBehavior
    include ESSI::PagedResourcesControllerBehavior
    include ESSI::RemoteMetadataLookupBehavior
    include Hyrax::BreadcrumbsForWorks
    include ESSI::BreadcrumbsForWorks
    include ESSI::OCRSearch
    include ESSI::StructureBehavior
    self.curation_concern_type = ::PagedResource

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PagedResourcePresenter

    def pdf
      return unless ESSI.config.dig(:essi, :allow_pdf_download) && current_ability.current_user.admin?
      resource = PagedResource.find(params[:id])
      pdf = ESSI::GeneratePdfService.new(resource).generate if resource

      send_file pdf[:file_path],
                filename: pdf[:file_name],
                type: 'application/pdf',
                disposition: 'inline'
    end
  end
end
