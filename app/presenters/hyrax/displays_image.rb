# a modified cherry-pick of Hyrax 3.x
# @todo remove after upgrade to Hyrax 3.x
require 'iiif_manifest'

module Hyrax
  # This gets mixed into FileSetPresenter in order to create
  # a canvas on a IIIF manifest
  module DisplaysImage
    extend ActiveSupport::Concern

    # Creates a display image only where FileSet is an image.
    #
    # @return [IIIFManifest::DisplayImage] the display image required by the manifest builder.
    def display_image
      return nil unless solr_document.image? && current_ability.can?(:read, id)
      return nil unless iiif_path_service.lookup_id

      # @see https://github.com/samvera-labs/iiif_manifest
      IIIFManifest::DisplayImage.new(iiif_path_service.iiif_image_url,
                                     width: width,
                                     height: height,
                                     iiif_endpoint: iiif_endpoint)
    end

    private
      def iiif_path_service
        @iiif_path_service ||= IIIFFileSetPathService.new(solr_document)
      end

      def iiif_endpoint
        return unless Hyrax.config.iiif_image_server?
        IIIFManifest::IIIFEndpoint.new(
          iiif_path_service.iiif_info_url(request.base_url),
          profile: Hyrax.config.iiif_image_compliance_level_uri
        )
      end
  end
end
