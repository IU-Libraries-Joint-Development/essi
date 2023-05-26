# frozen_string_literal: true

# Triggers reindexing on all collections
class ReindexCollectionsJob < ApplicationJob
  def perform
    Collection.find_each do |col|
      Rails.logger.info "Reindexing #{col.class}: #{col.id}"
      col.update_index
    end
  end
end
