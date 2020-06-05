module ESSI
  class ManifestHelper < Hyrax::ManifestHelper
    include Rails.application.routes.url_helpers
    include ActionDispatch::Routing::PolymorphicRoutes

    # File is copied over from Hyrax for overriding methods

    # Build a rendering hash for pdf
    #
    # @return [Hash] rendering
    def build_pdf_rendering(file_set_id)
      file_set_document = query_for_rendering(file_set_id)
      label = file_set_document.label.present? ? ": #{file_set_document.label}" : ''
      {
        "@id"=> Hyrax::Engine.routes.url_helpers.download_url(file_set_document.id, host: @hostname),
        "label"=> "Download as PDF",
        "format"=> "application/pdf"
      }
    end
  end
end
