module FileSetDerivativesServiceExtensions
  def create_derivatives(filename)
    super
    case mime_type
      when *file_set.class.image_mime_types
        create_hocr_derivatives(filename)
    end
  end

  private
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
end

Hyrax::FileSetDerivativesService.class_eval do
  prepend FileSetDerivativesServiceExtensions
end
