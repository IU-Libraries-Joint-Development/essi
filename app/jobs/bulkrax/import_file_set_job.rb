# frozen_string_literal: true
# @todo drop this direct import after upgrading to bulkrax commit 0de8ee06 or later

module Bulkrax
  class MissingParentError < ::StandardError; end

  class ImportFileSetJob < ApplicationJob
    include DynamicRecordLookup

    queue_as Bulkrax.config.ingest_queue_name

    attr_reader :importer_run_id

    def perform(entry_id, importer_run_id)
      @importer_run_id = importer_run_id
      entry = Entry.find(entry_id)
      # e.g. "parents" or "parents_1"
      parent_identifier = (entry.raw_metadata[entry.related_parents_raw_mapping] || entry.raw_metadata["#{entry.related_parents_raw_mapping}_1"])&.strip

      begin
        validate_parent!(parent_identifier)
      rescue MissingParentError => e
        handle_retry(entry, importer_run_id, e)
        return
      end

      entry.build
      if entry.succeeded?
        # rubocop:disable Rails/SkipsModelValidations
        ImporterRun.increment_counter(:processed_records, importer_run_id)
        ImporterRun.increment_counter(:processed_file_sets, importer_run_id)
      else
        ImporterRun.increment_counter(:failed_records, importer_run_id)
        ImporterRun.increment_counter(:failed_file_sets, importer_run_id)
        # rubocop:enable Rails/SkipsModelValidations
      end
      ImporterRun.decrement_counter(:enqueued_records, importer_run_id) unless ImporterRun.find(importer_run_id).enqueued_records <= 0 # rubocop:disable Rails/SkipsModelValidations
      entry.save!
      entry.importer.current_run = ImporterRun.find(importer_run_id)
      entry.importer.record_status
    end

    private

    attr_reader :parent_record

    def validate_parent!(parent_identifier)
      # if parent_identifier is missing, it will be caught by #validate_presence_of_parent!
      return if parent_identifier.blank?

      find_parent_record(parent_identifier)
      check_parent_is_a_work!(parent_identifier)
    end

    def check_parent_is_a_work!(parent_identifier)
      error_msg = %(A record with the ID "#{parent_identifier}" was found, but it was a #{parent_record.class}, which is not an valid/available work type)
      raise ::StandardError, error_msg unless curation_concern?(parent_record)
    end

    def find_parent_record(parent_identifier)
      _, @parent_record = find_record(parent_identifier, importer_run_id)
      raise MissingParentError, %(Unable to find a record with the identifier "#{parent_identifier}") unless parent_record
    end

    def handle_retry(entry, importer_run_id, e)
      entry.import_attempts += 1
      entry.save!
      if entry.import_attempts < 5
        ImportFileSetJob.set(wait: (entry.import_attempts + 1).minutes).perform_later(entry.id, importer_run_id)
      else
        ImporterRun.decrement_counter(:enqueued_records, importer_run_id) # rubocop:disable Rails/SkipsModelValidations
        entry.set_status_info(e)
      end
    end
  end
end
