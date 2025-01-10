# unmodified from bulkrax 5.5.1
module Extensions
  module Bulkrax
    module Exporter
      module ExportMetadataOnly
        def export_type_list
          [
            [I18n.t('bulkrax.exporter.labels.metadata'), 'metadata'],
            [I18n.t('bulkrax.exporter.labels.full'), 'full']
          ]
        end

        def metadata_only?
          export_type == 'metadata'
        end
      end
    end
  end
end
