# modified from bulkrax 5.5.1
module Extensions
  module Bulkrax
    module Exporter
      module ExportMetadataOnly
        # modified to remove option for files export
        def export_type_list
          [
            [I18n.t('bulkrax.exporter.labels.metadata'), 'metadata'],
            # [I18n.t('bulkrax.exporter.labels.full'), 'full']
          ]
        end

        # modified to never support file export
        def metadata_only?
          true # export_type == 'metadata'
        end
      end
    end
  end
end
