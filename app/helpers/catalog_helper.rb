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
    representative_document = ::SolrDocument.find(document.thumbnail_id)
    thumbnail_file_id = representative_document.original_file_id
    Hyrax.config.iiif_image_url_builder.call(thumbnail_file_id, nil, '250,') if thumbnail_file_id
  end
end
