module ESSI
  module OCRBehavior
    extend ActiveSupport::Concern

    def ocr_searchable?
      load_ocr_state
      self.try(:ocr_state) == 'searchable' # handle missing ocr_state property via try
    end

    def load_ocr_state
      unless self.respond_to?(:ocr_state)
        Rails.logger.warn "ocr_state property missing from #{self.class.to_s} item #{self.title} (#{self.id})"
        self.class.new # attempt loading unloaded flexible metadata profile
        if self.respond_to?(:ocr_state)
          Rails.logger.info "ocr_state property successfully loaded"
        else
          Rails.logger.warn "ocr_state property failed to load"
        end
      end
    end

    def to_solr(solr_doc = {})
      super.tap do |doc|
        doc[Solrizer.solr_name('ocr_searchable',
                               Solrizer::Descriptor.new(:boolean, :stored, :indexed))] = self.ocr_searchable?
      end
    end
  end
end
