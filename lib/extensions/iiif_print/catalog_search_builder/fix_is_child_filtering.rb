module Extensions
  module IiifPrint
    module CatalogSearchBuilder
      module FixIsChildFiltering
        # unmodified from iiif_print b804f16
        def show_parents_only(solr_parameters)
          query = if blacklight_params["include_child_works"] == 'true'
                    ::ActiveFedora::SolrQueryBuilder.construct_query(is_child_bsi: 'true')
                  else
                    ::ActiveFedora::SolrQueryBuilder.construct_query(is_child_bsi: nil)
                  end
          solr_parameters[:fq] += [query]
        end
      end
    end
  end
end
