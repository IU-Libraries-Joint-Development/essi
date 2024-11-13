module Extensions
  module IiifPrint
    module ManifestMetadata
      def self.included(base)
        base.class_eval do
          # unmodified from iiif_print
          def self.manifest_metadata_from(work:, presenter:)
            current_ability = presenter.try(:ability) || presenter.try(:current_ability)
            base_url = presenter.try(:base_url) || presenter.try(:request)&.base_url
            ::IiifPrint.manifest_metadata_for(work: work, current_ability: current_ability, base_url: base_url)
          end
        end
      end
    end
  end
end
