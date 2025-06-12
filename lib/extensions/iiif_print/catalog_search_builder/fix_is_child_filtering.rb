module Extensions
  module IiifPrint
    module CatalogSearchBuilder
      module FixIsChildFiltering
        # modified from iiif_print b804f16
        # drops broken filter for else case, iiif_print issue #389
        def show_parents_only(solr_parameters)
          query = if blacklight_params["include_child_works"] == 'true'
                    ::ActiveFedora::SolrQueryBuilder.construct_query(is_child_bsi: 'true')
                  else
                    nil # ::ActiveFedora::SolrQueryBuilder.construct_query(is_child_bsi: nil)
                  end
          solr_parameters[:fq] += [query] if query
        end
      end
    end
  end
end
