# frozen_string_literal: true

class ReindexFileSetsJob < ApplicationJob
  def perform(file_set_ids = [], opts = {})
    start_time = opts.dig(:start_time) || Time.now.strftime("%Y-%m-%d_%H%M%S")
    @reindex_logger = Logger.new(Rails.root.join('log', "reindex_file_sets_#{start_time}.log"))
    index_query_field = opts.dig(:index_query_field) || 'iiif_index_strategy_tesim'
    index_query_value = opts.dig(:index_query_value) || IndexerHelper.iiif_index_strategy
    row_count = opts.dig(:row_count) || 500
    sleep_break = opts.dig(:sleep_break) || 10
    if file_set_ids.empty?
      index_query = "-#{index_query_field}:#{index_query_value}"
      model_query = "has_model_ssim:FileSet"
      loop do
        results = ActiveFedora::SolrService.instance.conn.get(
          ActiveFedora::SolrService.select_path,
          params: { qt: "search", q: [model_query], fq: [index_query], fl: "id", rows: row_count}
        )

        break if results["response"]["numFound"] == 0

        results["response"]["docs"].each do |solr_hit|
          index_file_set(solr_hit["id"])
        end
        # Give the backend and the jobs a break...
        sleep sleep_break
      end
    else
      file_set_ids.each do |id|
        index_file_set(id)
      end
    end
  end

  private

    def index_file_set(id)
      begin
        fs = FileSet.find(id)
        FileSet.new
        @reindex_logger.info "Reindexing FileSet: #{id}"
        fs.update_index
      rescue => error
        @reindex_logger.error "ReindexFileSetsJob: Reindexing FileSet #{id} failed : #{error.message}"
      end
    end
end
