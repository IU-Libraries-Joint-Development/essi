# modified from iiif_print-b804f165ef61
# pull query parameter, if any, from standard params intead of blacklight Search
module Extensions
  module Hyrax
    module IiifHelper
      module PatchUvSearchParam
        # Extract query param from search
        def uv_search_param
          "&q=#{url_encode(params['query'])}" if params['query'].present? && params[:highlight]
        end  
      end
    end
  end
end
