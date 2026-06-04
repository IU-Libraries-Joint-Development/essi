# unmodified from blacklight_iiif_search v1.0.0
module Extensions
  module BlacklightIiifSearch
    module IiifSearchResponse
      module ResourcesMethod
        ##
        # Return an array of IiifSearchAnnotation objects
        # @return [Array]
        def resources
          @total = 0
          solr_response['highlighting'].each do |id, hl_hash|
            hit = { '@type': 'search:Hit', 'annotations': [] }
            document = solr_response.documents.select { |v| v[:id] == id }.first
            if hl_hash.empty?
              @total += 1
              annotation = ::BlacklightIiifSearch::IiifSearchAnnotation.new(document,
                                                                            solr_response.params['q'],
                                                                            0, nil, controller,
                                                                            @parent_document)
              @resources << annotation.as_hash
              hit[:annotations] << annotation.annotation_id
            else
              hl_hash.each_value do |hl_array|
                hl_array.each_with_index do |hl, hl_index|
                  @total += 1
                  annotation = ::BlacklightIiifSearch::IiifSearchAnnotation.new(document,
                                                                                solr_response.params['q'],
                                                                                hl_index, hl, controller,
                                                                                @parent_document)
                  @resources << annotation.as_hash
                  hit[:annotations] << annotation.annotation_id
                end
              end
            end
            @hits << hit
          end
          @resources
        end
      end
    end
  end
end
