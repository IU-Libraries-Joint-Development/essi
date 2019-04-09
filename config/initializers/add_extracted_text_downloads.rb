# Adds extracted text option to download files
# Example: http://example.edu/downloads/123456?file=extracted_text
module DownloadsControllerExtensions
  def load_file
    if params[:file] && params[:file] == 'extracted_text'
      association = dereference_file(:extracted_text)
      return association&.reader
    end
    super
  end
end

Rails.application.config.after_initialize do
  Hyrax::DownloadsController.class_eval do
    prepend DownloadsControllerExtensions
  end
end

# Makes extracted text check available in file details.
module FileSetPresenterExtensions
  def extracted_text?
    ::FileSet.find(id).extracted_text.present?
  end

  def extracted_text_link
    "/downloads/#{id}?file=extracted_text"
  end
end

Hyrax::FileSetPresenter.class_eval do
  prepend FileSetPresenterExtensions
end
