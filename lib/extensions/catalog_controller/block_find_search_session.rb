# unmodified from blacklight 6.25.0 Blacklight::SearchContext
module Extensions
  module CatalogController
    module BlockFindSearchSession
      def find_search_session
        if agent_is_crawler?
          nil
        elsif params[:search_context].present?
          find_or_initialize_search_session_from_params JSON.parse(params[:search_context])
        elsif params[:search_id].present?
          begin
            # TODO: check the search id signature.
            searches_from_history.find(params[:search_id])
          rescue ActiveRecord::RecordNotFound
            nil
          end
        elsif start_new_search_session?
          find_or_initialize_search_session_from_params search_state.to_h
        elsif search_session['id']
          begin
            searches_from_history.find(search_session['id'])
          rescue ActiveRecord::RecordNotFound
            nil
          end
        end
      end
    end
  end 
end
