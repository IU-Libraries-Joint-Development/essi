module ESSI
  module PDFBehavior
    extend ActiveSupport::Concern

    def pdf_downloadable?
      begin
        [self.pdf_state, self.pdf_state.try(:first)].include? 'downloadable'
      rescue => error
        Rails.logger.error "Error reading pdf_state for #{self.class} #{self.id}: #{error.message}"
        false
      end
    end

    def to_solr(solr_doc = {})
      super.tap do |doc|
        doc[Solrizer.solr_name('pdf_downloadable',
                               Solrizer::Descriptor.new(:boolean, :stored, :indexed))] = self.pdf_downloadable?
      end
    end
  end
end
