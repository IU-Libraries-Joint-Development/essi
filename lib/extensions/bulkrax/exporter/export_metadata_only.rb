# modified from bulkrax 5.5.1
module Extensions
  module Bulkrax
    module Exporter
      module ExportMetadataOnly
        # unmodified from bulkrax
        def export_from_list
          if defined?(::Hyrax)
            [
              [I18n.t('bulkrax.exporter.labels.importer'), 'importer'],
              [I18n.t('bulkrax.exporter.labels.collection'), 'collection'],
              [I18n.t('bulkrax.exporter.labels.worktype'), 'worktype'],
              [I18n.t('bulkrax.exporter.labels.all'), 'all']
            ]
          else
            [
              [I18n.t('bulkrax.exporter.labels.importer'), 'importer'],
              [I18n.t('bulkrax.exporter.labels.collection'), 'collection'],
              [I18n.t('bulkrax.exporter.labels.all'), 'all']
            ]
          end
        end

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
