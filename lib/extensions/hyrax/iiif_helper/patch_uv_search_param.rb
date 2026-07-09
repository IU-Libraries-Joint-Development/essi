# unmodified from iiif_print-b804f165ef61
module Extensions
  module Hyrax
    module IiifHelper
      module PatchUvSearchParam
        # Extract query param from search
        def uv_search_param
          search_params = current_search_session.try(:query_params) || {}
          q = search_params['q'].presence || ''
        
          "&q=#{url_encode(q)}" if q.present?
        end  
      end
    end
  end
end
