# frozen_string_literal: true

class ReindexWorksJob < ApplicationJob

  def perform(opts = {})
    index_query_field = opts.dig(:index_query_field) || 'iiif_index_strategy_tesim'
    index_query_value = opts.dig(:index_query_value) || IndexerHelper.iiif_index_strategy
    index_file_sets = opts.dig(:index_file_sets) || true
    async_fs_jobs = opts.dig(:async_fs_jobs) || false
    row_count = opts.dig(:row_count) || 100
    sleep_break = opts.dig(:row_count) || 10
    Hyrax.config.registered_curation_concern_types.each do |work_type|
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
          work_type.constantize.class.new
          begin
            work.update_index
          rescue Samvera::NestingIndexer::Exceptions::ExceededMaximumNestingDepthError
            Rails.logger.info "ReindexWorksJob: Children of #{work.class} #{work.id} not indexed; exceeds nested depth maximum."
          rescue => error
            Rails.logger.error "ReindexWorksJob: Reindexing #{work.id} failed,  #{error.message}"
          end
          perform_method = async_fs_jobs ? 'perform_later' : 'perform_now'
          ReindexFileSetsJob.send(perform_method.to_sym, (solr_hit["file_set_ids_ssim"])) if index_file_sets
        end

        # Give the backend and the jobs a break...
        sleep sleep_break
      end
    end
  end
end
