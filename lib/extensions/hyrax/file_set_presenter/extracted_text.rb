# Makes extracted text check available in file details.
module Extensions
  module Hyrax
    module FileSetPresenter
      module ExtractedText
        delegate :extracted_text, to: :solr_document
        
        def extracted_text?
          extracted_text.present?
        end
      
        def extracted_text_link
          "/downloads/#{id}?file=extracted_text"
        end

        # true when ocr file exists, even with no extracted_text content
        def ocr_file?
          solr_document['word_boundary_tsi'].present?
        end
      end
    end
  end 
end
