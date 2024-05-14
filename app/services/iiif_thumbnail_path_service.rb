class IIIFThumbnailPathService < Hyrax::WorkThumbnailPathService
  class << self
    # @return the network path to the thumbnail
    # @param [FileSet] thumbnail the object that is the thumbnail
    def thumbnail_path(thumbnail)
      return unless thumbnail.original_file
      id = thumbnail.content_location || thumbnail.original_file.id
      Hyrax.config.iiif_image_url_builder.call(id, nil, '250,')
      # Hyrax::Engine.routes.url_helpers.download_path(thumbnail.id,
      #                                                file: 'thumbnail')
    end

    # @return true if there a file in fedora for this object, otherwise false
    # @param [FileSet] thumb - the object that is the thumbnail
    def thumbnail?(thumb)
      thumb.files.size > 0
    end
  end
end
