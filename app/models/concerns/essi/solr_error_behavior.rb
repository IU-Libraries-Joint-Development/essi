module ESSI
  module SolrErrorBehavior
    extend ActiveSupport::Concern

    def to_solr(solr_doc = {})
      begin
        super
      rescue => e
        Rails.logger.error("Error in #to_solr for #{self.class.to_s} #{self.id}: #{e.inspect}")
        raise e
      end
    end
  end
end
