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
      #TODO: handle when not paged resource
      resource = PagedResource.find(params[:id])
      pdf_hash = generate_pdf(resource)

      send_file pdf_hash[:path],
        filename: pdf_hash[:file_name],
        type: 'application/pdf',
        disposition: 'inline'
    end

      private

     def generate_pdf(resource)
       path = Rails.root.join('tmp', 'pdfs')
       file_name = "#{resource.id}.pdf"
       pdf_file = nil
       file_path = Rails.root.join(path, file_name)

       FileUtils.mkdir_p path unless File.exist?(path)
       File.delete(file_path) if File.exists?(file_path)
       Prawn::Document.generate(Rails.root.join('tmp', 'pdfs', file_name)) do |pdf|
         resource.file_sets.each do |fs|
           pdf_file = Tempfile.create(fs.original_file.file_name.first, path) do |file|
             file.binmode
             file.write(fs.original_file.content)
             pdf.image(file)
           end
         end
       end

       { path: file_path, file_name: file_name }
     end
  end
end
