module Extensions
  module IiifPrint
    module ManifestMetadata
      def self.included(base)
        base.class_eval do
          # modified from iiif_print to receive fields
          def self.manifest_metadata_from(work:, presenter:, fields: default_metadata_fields)
            current_ability = presenter.try(:ability) || presenter.try(:current_ability)
            base_url = presenter.try(:base_url) || presenter.try(:request)&.base_url
            ::IiifPrint.manifest_metadata_for(work: work, current_ability: current_ability, base_url: base_url, fields: fields)
          end

          def self.default_metadata_fields
            defined?(::AllinsonFlex) ? fields_for_allinson_flex : default_fields
          end
        end
      end
    end
  end
end
