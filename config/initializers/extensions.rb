# active fedora node cache initialization
ActiveFedora::Orders::OrderedList.prepend Extensions::ActiveFedora::Orders::OrderedList::InitializeNodeCache

# extracted text support
Rails.application.config.after_initialize do
  Hyrax::DownloadsController.prepend Extensions::Hyrax::DownloadsController::ExtractedText
end
Hyrax::FileSetPresenter.include Extensions::Hyrax::FileSetPresenter::ExtractedText

# viewing hint support
IIIFManifest::ManifestBuilder::ImageBuilder.include Extensions::IIIFManifest::ManifestBuilder::ImageBuilder::ViewingHint
Hyrax::Forms::FileManagerForm.include Extensions::Hyrax::Forms::FileManagerForm::ViewingMetadata
Hyrax::FileSetPresenter.include Extensions::Hyrax::FileSetPresenter::ViewingHint

# primary fields support
Hyrax::Forms::WorkForm.class_eval { include Extensions::Hyrax::Forms::WorkForm::PrimaryFields }

# TODO: determine if needed?
# iiif manifest support
Hyrax::WorkShowPresenter.prepend Extensions::Hyrax::WorkShowPresenter::ManifestMetadata
