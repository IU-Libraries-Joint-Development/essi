# Generated via
#  `rails generate hyrax:work PagedResource`
module Hyrax
  class PagedResourcePresenter < Hyrax::WorkShowPresenter
    include ESSI::PresentsOCR
    include ESSI::PresentsStructure
    delegate :series, :viewing_direction, :viewing_hint,
             to: :solr_document

    def holding_location
      HoldingLocationAttributeRenderer.new(solr_document.holding_location).render_dl_row
    end

    # Overrides hyrax
    # IIIF rendering linking property for inclusion in the manifest
    #  Called by the `iiif_manifest` gem to add a 'rendering' (eg. a link a download for the resource)
    #
    # @return [Array] array of rendering hashes
    def sequence_rendering
      renderings = []
      if solr_document.rendering_ids.present?
        solr_document.rendering_ids.each do |file_set_id|
          renderings << manifest_helper.build_rendering(file_set_id)
          renderings << manifest_helper.build_pdf_rendering(file_set_id)
        end
      end
      renderings.flatten
    end

    def manifest_helper
      @manifest_helper ||= ESSI::ManifestHelper.new(request.base_url)
    end
  end
end
