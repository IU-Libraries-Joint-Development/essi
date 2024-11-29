require Rails.root.join('lib', 'newspaper_works.rb')

module ESSI
  class FileSetIndexer < Hyrax::FileSetIndexer
    include ESSI::IIIFThumbnailBehavior

    def generate_solr_document
      super.tap do |solr_doc|
        parent = object.parent
        collection_branding_info = object.collection_branding_info
        if parent
          solr_doc['parented_bsi'] = true
          solr_doc['collection_branding_bsi'] = false
          solr_doc['is_page_of_ssi'] = parent.id
          solr_doc['parent_path_tesi'] = Rails.application.routes.url_helpers.polymorphic_path(parent)
        elsif collection_branding_info
          solr_doc['parented_bsi'] = false
          solr_doc['collection_branding_bsi'] = true
          solr_doc['is_collection_brand_of_ssi'] = collection_branding_info.collection_id
        else
          solr_doc['parented_bsi'] = false
          solr_doc['collection_branding_bsi'] = false
        end

        solr_doc['word_boundary_tsi'] = IiifPrint::TextExtraction::AltoReader.new(object.extracted_text.content).json if object.extracted_text.present?
        solr_doc[Solrizer.solr_name('iiif_index_strategy')] = IndexerHelper.iiif_index_strategy

        # Records storage location of the file. e.g. 's3' if in external storage
        solr_doc['content_location_ssi'] = object.content_location if object.content_location.present?
      end
    end
  end
end
