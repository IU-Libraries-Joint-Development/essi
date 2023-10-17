require Rails.root.join('lib', 'newspaper_works.rb')

module ESSI
  class FileSetIndexer < Hyrax::FileSetIndexer
    include ESSI::IIIFThumbnailBehavior

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['is_page_of_ssi'] = object.parent.id if object.parent
        solr_doc['parent_path_tesi'] = Rails.application.routes.url_helpers.polymorphic_path(object.parent) if object.parent
        solr_doc['word_boundary_tsi'] = IiifPrint::TextExtraction::AltoReader.new(object.extracted_text.content).json if object.extracted_text.present?
        solr_doc[Solrizer.solr_name('iiif_index_strategy')] = IndexerHelper.iiif_index_strategy
      end
    end
  end
end
