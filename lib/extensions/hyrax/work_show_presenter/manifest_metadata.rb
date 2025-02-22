# TODO Decide if we need this, or can use the stock Hyrax code, or the newer Hyrax code
module Extensions
  module Hyrax
    module WorkShowPresenter
      module ManifestMetadata
        # Copied from Hyrax gem
        # IIIF metadata for inclusion in the manifest
        #  Called by the `iiif_manifest` gem to add metadata
        #
        # @return [Array] array of metadata hashes
        def manifest_metadata
          # Using IIIF Print's approach to display parent metadata
          iiif_manifest_presenter = ::Hyrax::IiifManifestPresenter.new(self)
          iiif_manifest_presenter.ability = current_ability
          iiif_manifest_presenter.manifest_metadata(fields: sorted_manifest_fields)
        end

        def public_view_properties
          @public_view_properties ||= dynamic_schema_service.view_properties.reject { |k,v| v[:admin_only] }
        end

        Field = Struct.new(:name, :value, :indexing, keyword_init: true)

        def manifest_fields
          @manifest_fields ||= dynamic_schema_service.send(:properties).map do |prop|
            Field.new(name: prop[0], value: prop[1][:display_label], indexing: prop[1][:indexing])
          end
        end

        def sorted_manifest_fields
          @sorted_manifest_fields ||= ::IiifPrint.fields_for_allinson_flex(fields: manifest_fields)
        end
      end
    end
  end
end
