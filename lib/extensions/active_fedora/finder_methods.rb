module Extensions
  module ActiveFedora
    module FinderMethods
      def search_in_batches(conditions, opts = {})
        opts[:q] = create_query(conditions)
        opts[:qt] = @klass.solr_query_handler
        # set default sort to created date ascending
        opts[:sort] = @klass.default_sort_params unless opts[:sort].present?
        opts[:method] ||= :post

        batch_size = opts.delete(:batch_size) || 1000
        select_path = ::ActiveFedora::SolrService.select_path

        counter = 0
        loop do
          counter += 1
          response = ::ActiveFedora::SolrService.instance.conn.paginate counter, batch_size, select_path,
                                                                      { params: opts, method: opts[:method] }
          docs = response["response"]["docs"]
          yield docs
          break unless docs.has_next?
        end
      end
    end
  end
end