# frozen_string_literal: true

# Triggers reindexing on all collections
class ReindexCollectionsJob < ApplicationJob
  def perform
    Collection.find_each do |col|
      Rails.logger.info "Reindexing #{col.class}: #{col.id}"
      begin
        col.update_index
      rescue Samvera::NestingIndexer::Exceptions::ExceededMaximumNestingDepthError
        Rails.logger.info "ReindexCollectionsJob: Children of #{col.class} #{col.id} not indexed; exceeds nested depth maximum."
      rescue => error
        Rails.logger.error "ReindexCollectionsJob: Reindexing #{col.id} failed,  #{error.message}"
      end
    end
  end
end
