module ESSI
  module PagedResourceBehavior
    extend ActiveSupport::Concern
    # Add behaviors that make this work type unique
    included do
      before_save :set_num_pages

      def ocr_searchable?
        return true if self.ocr_state == 'searchable'
        return false
      end
    end

    def to_solr(solr_doc = {})
      super.tap do |doc|
        doc[Solrizer.solr_name('ocr_searchable',
                               Solrizer::Descriptor.new(:boolean, :stored, :indexed))] = self.ocr_searchable?
      end
    end

  private

    def set_num_pages
      self.num_pages = self.member_ids.size
    end

  end
end
