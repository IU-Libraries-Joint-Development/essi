# frozen_string_literal: true

class ReindexWorksJob < ApplicationJob

  def perform(opts = {})
    start_time = Time.now.strftime("%Y-%m-%d_%H%M%S")
    reindex_logger = Logger.new(Rails.root.join('log', "reindex_works_#{start_time}.log"))
    index_query_field = opts.dig(:index_query_field) || 'iiif_index_strategy_tesim'
    index_query_value = opts.dig(:index_query_value) || IndexerHelper.iiif_index_strategy
    index_file_sets = opts.dig(:index_file_sets) || true
    async_fs_jobs = opts.dig(:async_fs_jobs) || false
    row_count = opts.dig(:row_count) || 100
    sleep_break = opts.dig(:sleep_break) || 10
    curation_concern_types = opts.dig(:work_types) || Hyrax.config.registered_curation_concern_types
    curation_concern_types.each do |work_type|
      index_query = "-#{index_query_field}:#{index_query_value}"
      model_query = "has_model_ssim:#{work_type.constantize}"
      loop do
        results = ActiveFedora::SolrService.instance.conn.get(
          ActiveFedora::SolrService.select_path,
          params: { qt: "search", q: [model_query], fq: [index_query], fl: "id,file_set_ids_ssim", rows: row_count}
        )

        break if results["response"]["numFound"] == 0

        results["response"]["docs"].each do |solr_hit|
          begin
            # This reloads the latest profile to ensure that we get all possible properties
            work_type.constantize.new
            work = work_type.constantize.find(solr_hit["id"])
            reindex_logger.info "ReindexWorksJob: Reindexing #{work_type} #{solr_hit["id"]}"
            work.update_index
          rescue Samvera::NestingIndexer::Exceptions::ExceededMaximumNestingDepthError
            reindex_logger.error "ReindexWorksJob: Children of #{work_type} #{solr_hit["id"]} not indexed; exceeds nested depth maximum."
          rescue => error
            reindex_logger.error "ReindexWorksJob: Reindexing #{work_type} #{solr_hit["id"]} failed :  #{error.message}"
          end
          unless solr_hit["file_set_ids_ssim"].blank?
            perform_method = async_fs_jobs ? 'perform_later' : 'perform_now'
            ReindexFileSetsJob.send(perform_method.to_sym, solr_hit["file_set_ids_ssim"], {start_time: start_time}) if index_file_sets
          end
        end

        # Give the backend and the jobs a break...
        reindex_logger.info "ReindexWorksJob resting for #{sleep_break}"
        sleep sleep_break
      end
    end
  end
end
