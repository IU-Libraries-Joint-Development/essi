# Overriding the solr_params method to include the object relation field used before iiif_print.
module Extensions
  module IiifPrint
    module IiifSearchDecorator
      module SearchDecoratorCompatibility
        def self.included(base)
          base.class_eval do
            ##
            # @return [Hash] A hash containing the modified Solr search parameters
            #
            def solr_params
              return { q: 'nil:nil' } unless q

              search_fields = ''
              search_fields << "#{iiif_config[:object_relation_field]}:\"#{parent_document.id}\""
              search_fields << " OR #{iiif_config[:extra_relation_field]}:\"#{parent_document.id}\""
              search_fields << " OR id:\"#{parent_document.id}\""
              {
                q: "#{q} AND (#{search_fields})",
                rows: rows,
                page: page
              }
            end
          end
        end
      end
    end
  end
end
