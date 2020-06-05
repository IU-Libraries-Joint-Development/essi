module Hyrax
  class ManifestHelper
    include Rails.application.routes.url_helpers
    include ActionDispatch::Routing::PolymorphicRoutes

    #File is copied over from Hyrax for overriding methods

    def initialize(hostname)
      @hostname = hostname
    end

    def polymorphic_url(record, opts = {})
      opts[:host] ||= @hostname
      super(record, opts)
    end

    # Build a rendering hash
    #
    # @return [Hash] rendering
    def build_rendering(file_set_id)
      file_set_document = query_for_rendering(file_set_id)
      label = file_set_document.label.present? ? ": #{file_set_document.label}" : ''
      mime = file_set_document.mime_type.present? ? file_set_document.mime_type : I18n.t("hyrax.manifest.unknown_mime_text")
      {
        '@id' => Hyrax::Engine.routes.url_helpers.download_url(file_set_document.id, host: @hostname),
        'format' => mime,
        'label' => I18n.t("hyrax.manifest.download_text") + label
      }
    end

    # Build a rendering hash
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

    # Query for the properties to create a rendering
    #
    # @return [SolrDocument] query result
    def query_for_rendering(file_set_id)
      ::SolrDocument.find(file_set_id)
    end
  end
end

