module Extensions
  module Hyrax
    module WorkShowPresenter
      module CollectionBanner
        def collection
          return @collection if @collection
          return false if member_of_collection_ids.empty?
          solr_hit = Collection.search_with_conditions(id: member_of_collection_ids.first).first
          @collection = SolrDocument.new(solr_hit) if solr_hit
          return @collection
        end
      end
    end
  end
end
