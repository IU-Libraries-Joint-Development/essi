# frozen_string_literal: true

# Triggers reindexing on all works
class ReindexWorksJob < ApplicationJob
  def perform
    Hyrax.config.registered_curation_concern_types.each do |work_type|
      work_type.constantize.find_each do |work|
        Rails.logger.info "Reindexing #{work.class}: #{work.id}"
        begin
          work.update_index
        rescue Samvera::NestingIndexer::Exceptions::ExceededMaximumNestingDepthError
          Rails.logger.info "ReindexWorksJob: Children of #{work.class} #{work.id} not indexed; exceeds nested depth maximum."
        rescue => error
          Rails.logger.error "ReindexWorksJob: Reindexing #{work.id} failed,  #{error.message}"
        end
      end
    end
  end
end
