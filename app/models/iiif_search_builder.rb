# frozen_string_literal: true

# SearchBuilder for full-text searches with highlighting and snippets
class IiifSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += [:ocr_search_params]

  # set params for ocr field searching
  def ocr_search_params(solr_parameters = {})
    solr_parameters[:facet] = false
    solr_parameters[:hl] = true
    # Until reindexing for iiif_print is complete, we don't know which text field a match will occur in.
    # Fortunately, Solr allows globbing when defining what field names to markup by the snippet processor.
    solr_parameters[:'hl.fl'] = '*text*'
    solr_parameters[:'hl.fragsize'] = 100
    solr_parameters[:'hl.snippets'] = 10
  end
end
