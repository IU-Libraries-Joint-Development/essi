# modified from blacklight_iiif_search v1.0.0
# changes behavior to return every match on a page, instead of only the first
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
            hl_hash = substitute_hash(hl_hash, document)
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

        def substitute_hash(hash, document)
          annotation = ::BlacklightIiifSearch::IiifSearchAnnotation.new(document,
                                                                        solr_response.params['q'],
                                                                        0, nil, controller,
                                                                        @parent_document)

          coords_json = annotation.send :fetch_and_parse_coords
          query = annotation.query.gsub(annotation.additional_query_terms, '')
          query_terms = query.split(' ').map(&:downcase)
          matches = coords_json['coords'].select { |k, _v| k.downcase =~ /(#{query_terms.join('|')})/ }
          if matches.size > 1
            coords_array = matches.values.flatten(1)
            { _key: Array.new(coords_array.size, nil) }
          else
            hash
          end
        end
      end
    end
  end
end
