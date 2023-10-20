# frozen_string_literal: true

class ReindexWorksJob < ApplicationJob

  def perform(opts = {})
    reindex_logger = Logger.new(Rails.root.join('log', 'reindex_works.log'))
    index_query_field = opts.dig(:index_query_field) || 'iiif_index_strategy_tesim'
    index_query_value = opts.dig(:index_query_value) || IndexerHelper.iiif_index_strategy
    index_file_sets = opts.dig(:index_file_sets) || true
    async_fs_jobs = opts.dig(:async_fs_jobs) || false
    row_count = opts.dig(:row_count) || 100
    sleep_break = opts.dig(:sleep_break) || 10
    Hyrax.config.registered_curation_concern_types.each do |work_type|
      # This helps ensure that we get all possible properties from the latest profile for each work type
      work_type.constantize.new
      index_query = "-#{index_query_field}:#{index_query_value}"
      model_query = "has_model_ssim:#{work_type.constantize}"
      loop do
        results = ActiveFedora::SolrService.instance.conn.get(
          ActiveFedora::SolrService.select_path,
          params: { qt: "search", q: [model_query], fq: [index_query], fl: "id,file_set_ids_ssim", rows: row_count}
        )

        break if results["response"]["numFound"] == 0

        results["response"]["docs"].each do |solr_hit|
          work = work_type.constantize.find(solr_hit["id"])
          # TODO This still seems to be necessary; does loading works with different profiles affect the available properties?
          work_type.constantize.class.new
          begin
            reindex_logger.info "ReindexWorksJob: Reindexing #{work&.id} started..."
            work.update_index
          rescue Samvera::NestingIndexer::Exceptions::ExceededMaximumNestingDepthError
            reindex_logger.error "ReindexWorksJob: Children of #{work.class} #{work.id} not indexed; exceeds nested depth maximum."
          rescue => error
            reindex_logger.error "ReindexWorksJob: Reindexing #{work&.id} failed,  #{error.message}"
          end
          unless solr_hit["file_set_ids_ssim"].blank?
            perform_method = async_fs_jobs ? 'perform_later' : 'perform_now'
            ReindexFileSetsJob.send(perform_method.to_sym, (solr_hit["file_set_ids_ssim"])) if index_file_sets
          end
        end

        # Give the backend and the jobs a break...
        reindex_logger.info "ReindexWorksJob resting for #{sleep_break}"
        sleep sleep_break
      end
    end
  end
end
