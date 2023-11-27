# frozen_string_literal: true

# Triggers reindexing on all collections
class ReindexCollectionsJob < ApplicationJob
  def perform
    Collection.find_each do |col|
      reindex_logger = Logger.new(Rails.root.join('log', 'reindex_collections.log'))
      begin
        reindex_logger.info "Reindexing #{col.class}: #{col.id} started..."
        col.update_index
      rescue Samvera::NestingIndexer::Exceptions::ExceededMaximumNestingDepthError
        reindex_logger.error "ReindexCollectionsJob: Children of #{col.class} #{col.id} not indexed; exceeds nested depth maximum."
      rescue => error
        reindex_logger.error "ReindexCollectionsJob: Reindexing #{col.id} failed,  #{error.message}"
      end
    end
  end
end
