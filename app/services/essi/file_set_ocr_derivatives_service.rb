module ESSI
  class FileSetOCRDerivativesService < Hyrax::FileSetDerivativesService
    def create_derivatives(filename)
      return if ESSI.config.dig(:essi, :skip_derivatives)

      super
      return if copy_hocr_derivatives(filename)

      create_hocr_derivatives(filename)
      create_word_boundaries
    end

    private

    def supported_mime_types
      file_set.class.image_mime_types
    end

    def copy_hocr_derivatives(filename)
      Rails.logger.info 'Checking for a Pre-derived OCR folder.'
      return false unless ESSI.config.dig(:essi, :derivatives_folder)

      Rails.logger.info 'Checking for a Pre-derived OCR File.'
      ocr_filename = "#{File.basename(filename, '.*')}.hocr"
      ocr_file = File.join(ESSI.config.dig(:essi, :derivatives_folder), ocr_filename)
      return false unless File.exist?(ocr_file)

      Rails.logger.info 'Copying for a Pre-derived OCR File.'
      CopyOCRRunner.create(ocr_file,
                           {source: ocr_file,
                           outputs: [{
                               label: ocr_filename,
                               mime_type: 'test/html;charset-UTF-8',
                               format: 'hocr',
                               container: 'extracted_text',
                               url: uri
                                     }]})

      # Rails.logger.info 'Using a Pre-derived OCR File.'
      # file_set.extracted_text = Hydra::PCDM::File.new
      # file_set.extracted_text.content = File.open(ocr_file)
      # file_set.extracted_text.mime_type = 'text/html;charset=UTF-8'
      # file_set.extracted_text.original_name = ocr_filename
      # file_set.extracted_text.save
      # file_set.save
      # true
    end

    def create_hocr_derivatives(filename)
      return unless ESSI.config.dig(:essi, :create_hocr_files)
      OCRRunner.create(filename,
                       { source: :original_file,
                         outputs: [{ label: "#{file_set.id}-hocr.hocr",
                                     mime_type: 'text/html; charset=utf-8',
                                     format: 'hocr',
                                     container: 'extracted_text',
                                     language: file_set.ocr_language,
                                     url: uri }]})
    end

    def create_word_boundaries
      return unless ESSI.config.dig(:essi, :create_word_boundaries)
      file_set.reload
      return unless file_set.extracted_text.present?
      WordBoundariesRunner.create(file_set,
                       { source: :extracted_text,
                         outputs: [{ label: "#{file_set.id}-json.json",
                                     mime_type: 'application/json; charset=utf-8',
                                     format: 'json',
                                     container: 'transcript',
                                     url: uri }]})
    end
  end
end
