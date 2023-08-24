# frozen_string_literal: true

# Triggers reindexing on all FileSets
class ReindexFileSetsJob < ApplicationJob
  def perform
    FileSet.find_each do |fs|
      Rails.logger.info "Reindexing #{fs.class}: #{fs.id}"
      fs.update_index
    end
  end
end
