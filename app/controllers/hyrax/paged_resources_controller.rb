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
      # PagedResourcePDF.new(presenter, quality: params[:pdf_quality]).render(pdf_hyrax_paged_resource_path)
      # redirect_to main_app.download_path(presenter)

      resource = PagedResource.find(params[:id])
      # TODO: if tmp/pdfs/ doesn't exist, mkdir it
      Prawn::Document.generate(Rails.root.join("tmp", "pdfs", "#{resource.id}.pdf")) do |pdf|
        resource.file_sets.each do |fs|
          Tempfile.create(fs.original_file.file_name.first, binmode: true) do |file|
            file.write(fs.original_file.content)
            pdf.image file.path
          end
        end
      end
    end

    # private

    # def pdf_type
      # "#{params[:pdf_quality]}-pdf"
    # end
  end
end
