module Extensions
  module IiifPrint
    module HighlightSearchParams
      module HighlightSearchParamsCompatibility
        def self.included(base)
          base.class_eval do
            # Override in order to add weightMatches = false for Solr 8+ compatibility
            def highlight_search_params(solr_parameters = {})
              return unless solr_parameters[:q] || solr_parameters[:all_fields]
              solr_parameters[:hl] = true
              solr_parameters[:'hl.fl'] = '*'
              solr_parameters[:'hl.fragsize'] = 100
              solr_parameters[:'hl.snippets'] = 5
              solr_parameters[:'hl.requiredFieldMatch'] = true
              solr_parameters[:'hl.weightMatches'] = false
            end
          end
        end
      end
    end
  end
end

