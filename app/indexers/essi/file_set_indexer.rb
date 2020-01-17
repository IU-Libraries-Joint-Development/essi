module ESSI
  class FileSetIndexer < Hyrax::FileSetIndexer
    include ESSI::IIIFThumbnailBehavior

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['is_page_of_ssi'] = object.parent.id if object.parent
        solr_doc['text_tesim'] = object.extracted_text.content if object.extracted_text.present?
        # @todo remove after upgrade to Hyrax 3.x
        solr_doc['original_file_id_ssi'] = original_file_id
      end
    end

    private

      # @todo remove after upgrade to Hyrax 3.x
      def original_file_id
        return unless object.original_file
        # Hyrax::VersioningService.versioned_file_id object.original_file
        versioned_file_id(object.original_file)
      end

      # @todo remove after upgrade to Hyrax 3.x
      # cherry-picked from Hyrax 3.x VersioningService
      # @param [ActiveFedora::File | Hyrax::FileMetadata] content
      def versioned_file_id(file)
        versions = file.versions.all
        if versions.present?
          ActiveFedora::File.uri_to_id versions.last.uri
        else
          file.id
        end
      end
  end
end

