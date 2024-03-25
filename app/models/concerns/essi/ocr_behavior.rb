module ESSI
  module OCRBehavior
    extend ActiveSupport::Concern

    def ocr_searchable?
      begin
        self.ocr_state == 'searchable'
      rescue => error
        Rails.logger.error "Error reading ocr_state for #{self.class} #{self.id}: #{error.message}"
        false
      end
    end

    def to_solr(solr_doc = {})
      super.tap do |doc|
        doc[Solrizer.solr_name('ocr_searchable',
                               Solrizer::Descriptor.new(:boolean, :stored, :indexed))] = self.ocr_searchable?
        doc[Solrizer.solr_name('iiif_index_strategy')] = IndexerHelper.iiif_index_strategy
      end
    end
  end
end
