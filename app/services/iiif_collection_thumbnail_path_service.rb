class IIIFCollectionThumbnailPathService < Hyrax::CollectionThumbnailPathService
  class << self
    # @return the network path to the thumbnail
    # @param [FileSet] thumbnail the object that is the thumbnail
    def thumbnail_path(thumbnail)
      IIIFFileSetPathService.new(thumbnail).iiif_image_url(size: '250,')
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
