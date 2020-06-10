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
      resource = PagedResource.find(params[:id])
      generate_pdf(resource)

      #raise 'hell'
      redirect_to hyrax.download_path(presenter)
    end

     private

     def generate_pdf(resource)
       path = Rails.root.join('tmp', 'pdfs')
       FileUtils.mkdir_p path unless File.exist?(path)
       file_name = "#{resource.id}.pdf"
       pdf_file = nil
       Prawn::Document.generate(Rails.root.join("tmp", "pdfs", file_name)) do |pdf|
         resource.file_sets.each do |fs|
           # TODO: check if tmpfile exists
           pdf_file = Tempfile.create(fs.original_file.file_name.first, path) do |file|
             file.binmode
             file.write(fs.original_file.content)
             pdf.image(file)
           end
         end
       end

      raise 'hell'
       pdf_file
     end
  end
end
