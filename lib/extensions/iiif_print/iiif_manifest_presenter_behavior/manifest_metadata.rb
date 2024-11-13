module Extensions
  module IiifPrint
    module IiifManifestPresenterBehavior
      module ManifestMetadata
        def self.included(base)
          base.class_eval do
            # unmodified from iiif_print
            def manifest_metadata
              # ensure we are using a SolrDocument
              @manifest_metadata ||= IiifPrint.manifest_metadata_from(work: model.solr_document, presenter: self)
            end
          end
        end
      end
    end
  end
end
