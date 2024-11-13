module Extensions
  module IiifPrint
    module IiifManifestPresenterBehavior
      module ManifestMetadata
        def self.included(base)
          base.class_eval do
            # modified from iiif_print to optionally receive fields
            def manifest_metadata(fields: ::IiifPrint.default_metadata_fields)
              # ensure we are using a SolrDocument
              @manifest_metadata ||= ::IiifPrint.manifest_metadata_from(work: model.solr_document, presenter: self, fields: fields)
            end
          end
        end
      end
    end
  end
end
