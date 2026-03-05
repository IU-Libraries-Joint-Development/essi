# frozen_string_literal: true
module Extensions
  module ActiveFedora
    module SolrService
      # Modified from active_fedora 12.2.4 solr_service.rb
      # to use POST by default
      def query(query, args = {})
        Base.logger.warn "Calling ActiveFedora::SolrService.get without passing an explicit value for ':rows' is not recommended. You will end up with Solr's default (usually set to 10)\nCalled by #{caller[0]}" unless args.key?(:rows)
        method = args.delete(:method) || :post

        result = case method
                 when :get
                   get(query, args)
                 when :post
                   post(query, args)
                 else
                   raise "Unsupported HTTP method for querying SolrService (#{method.inspect})"
                 end
        result['response']['docs'].map do |doc|
          ActiveFedora::SolrHit.new(doc)
        end
      end

      def count(query, args = {})
        args = args.merge(rows: 0)
        SolrService.post(query, args)['response']['numFound'].to_i
      end
    end
  end
end