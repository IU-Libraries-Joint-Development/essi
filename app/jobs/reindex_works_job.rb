# frozen_string_literal: true

# Triggers reindexing on all works
class ReindexWorksJob < ApplicationJob
  def perform
    Hyrax.config.registered_curation_concern_types.each do |work_type|
      work_type.constantize.find_each do |work|
        Rails.logger.info "Reindexing #{work.class}: #{work.id}"
        work.update_index
      end
    end
  end
end