# frozen_string_literal: true
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  ##
  # Get the URL to a document's thumbnail image
  # Overrides Blacklight behaviour
  #
  # @param [SolrDocument, Presenter] document
  # @return [String]
  def thumbnail_url document
    return document.thumbnail_path if document.try(:thumbnail_path).present?
    if document.id == document.thumbnail_id
      representative_document = document
    else
      representative_document = ::SolrDocument.find(document.thumbnail_id)
    end
    iiif_path_service = IIIFFileSetPathService.new(representative_document)
    if iiif_path_service.lookup_id
      iiif_path_service.iiif_image_url(size: '250,')
    else
      raise 'thumbnail_file_id is nil'
    end

  rescue StandardError => e
    Hyrax.logger.warn { "Failed to resolve thumbnail url for #{document&.id}: #{e.message}" }
    image_path 'default.png'
  end
end
