module Extensions
  module Hyrax
    module CollectionsController
      module LoadFromSolr
        # Loads curation_concern from solr
        def show
          @curation_concern ||= Collection.search_by_id(params[:id])
          super
        end

        private

        # The only use of collection_object passes it down to NestedCollectionsParentSearchBuilder
        # which can function with a solr document that responds to member_of_collection_ids.
        def collection_object
          # action_name == 'show' ? Collection.find(collection.id) : collection
          collection
        end
      end
    end
  end
end
