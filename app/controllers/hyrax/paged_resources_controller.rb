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
      # PagedResourcePDF.new(presenter).render(pdf_hyrax_paged_resource_path)
      # redirect_to main_app.download_path(presenter)

      resource = PagedResource.find(params[:id])
      generate_pdf(resource)
    end

     private

     def generate_pdf(resource)
       # TODO: if tmp/pdfs/ doesn't exist, mkdir it
       path = Rails.root.join('tmp', 'pdfs')
       FileUtils.mkdir_p path unless File.exist?(path)
       pdf_file = Prawn::Document.generate(Rails.root.join("tmp", "pdfs", "#{resource.id}.pdf")) do |pdf|
         resource.file_sets.each do |fs|
           Tempfile.create(fs.original_file.file_name.first, binmode: true) do |file|
             file.write(fs.original_file.content)
             pdf.image file.path
           end
         end
       end
       pdf_file
       raise 'hell'
     end
  end
end
