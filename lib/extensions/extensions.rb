# active fedora node cache initialization
ActiveFedora::Orders::OrderedList.prepend Extensions::ActiveFedora::Orders::OrderedList::InitializeNodeCache

# https://github.com/samvera/hyrax/issues/4581
# Source: https://github.com/avalonmediasystem/avalon/commit/b40dfc6834ee86c23138908f368af1a47bc69154
# Monkey-patch to short circuit ActiveModel::Dirty which attempts to load the whole master files ordered list when calling nodes_will_change!
# This leads to a stack level too deep exception when attempting to delete a master file from a media object on the manage files step.
# See https://github.com/samvera/active_fedora/pull/1312/commits/7c8bbbefdacefd655a2ca653f5950c991e1dc999#diff-28356c4daa0d55cbaf97e4269869f510R100-R103
ActiveFedora::Aggregation::ListSource.class_eval do
  def attribute_will_change!(attr)
    return super unless attr == 'nodes'
    attributes_changed_by_setter[:nodes] = true
  end
end

# external storage download support
Hyrax::DownloadsController.prepend Extensions::Hyrax::DownloadsController::ExternalStorage

# extracted text support
Hyrax::DownloadsController.prepend Extensions::Hyrax::DownloadsController::ExtractedText
Hyrax::FileSetPresenter.include Extensions::Hyrax::FileSetPresenter::ExtractedText
Hyrax::FileSetsController.include Extensions::Hyrax::FileSetsController::RegenerateOCR

# viewing hint support
IIIFManifest::ManifestBuilder::CanvasBuilder.prepend Extensions::IIIFManifest::ManifestBuilder::CanvasBuilder::ViewingHint
IIIFManifest::ManifestBuilder::ImageBuilder.prepend Extensions::IIIFManifest::ManifestBuilder::ImageBuilder::ViewingHint
Hyrax::Forms::FileManagerForm.include Extensions::Hyrax::Forms::FileManagerForm::ViewingMetadata
Hyrax::FileSetPresenter.include Extensions::Hyrax::FileSetPresenter::ViewingHint

# iiif manifest support for parent work when using IIIF Print
# this is responsible for displaying the parent metadata above the child metadata in the UV metadata pane
Hyrax::WorkShowPresenter.prepend Extensions::Hyrax::WorkShowPresenter::ManifestMetadata

# add campus logo information when available.
Hyrax::CollectionPresenter.prepend Extensions::Hyrax::CollectionPresenter::CampusLogo
Hyrax::WorkShowPresenter.prepend Extensions::Hyrax::WorkShowPresenter::CampusLogo
Hyrax::FileSetPresenter.prepend Extensions::Hyrax::FileSetPresenter::CampusLogo

# add collection banner to works and file sets.
Hyrax::FileSetPresenter.include Extensions::Hyrax::FileSetPresenter::CollectionBanner
Hyrax::WorkShowPresenter.include Extensions::Hyrax::WorkShowPresenter::CollectionBanner

# primary fields support
Hyrax::Forms::WorkForm.include Extensions::Hyrax::Forms::WorkForm::PrimaryFields
# support for worktype-specific #work_requires_files?
Hyrax::Forms::WorkForm.include Extensions::Hyrax::Forms::WorkForm::WorkRequiresFiles
# speedup work_members list generation by using solr
Hyrax::Forms::WorkForm.prepend Extensions::Hyrax::Forms::WorkForm::WorkMembersSpeedy

# IIIF Thumbnails for both types of Collections
Hyrax::AdminSetIndexer.include ESSI::IIIFCollectionThumbnailBehavior
Hyrax::CollectionIndexer.include ESSI::IIIFCollectionThumbnailBehavior

# Use FileSet to store and display collection banner/logo image
Hyrax::Forms::CollectionForm.prepend Extensions::Hyrax::Forms::CollectionForm::FileSetBackedBranding
Hyrax::CollectionPresenter.prepend Extensions::Hyrax::CollectionPresenter::FileSetBackedBranding
Hyrax::Dashboard::CollectionsController.prepend Extensions::Hyrax::Dashboard::CollectionsController::FileSetBackedBranding

# purl controller support
Hyrax::FileSetPresenter.include Extensions::Hyrax::FileSetPresenter::SourceMetadataIdentifier

## bulkrax overrides
Bulkrax::ObjectFactory.prepend Extensions::Bulkrax::ObjectFactory::Structure
Bulkrax::ObjectFactory.prepend Extensions::Bulkrax::ObjectFactory::RemoveUpdateFilesets
# bulkrax/allinson_flex integration support
Bulkrax::Entry.prepend Extensions::Bulkrax::Entry::AllinsonFlexFields
Bulkrax::Entry.prepend Extensions::Bulkrax::Entry::SingularizeRightsStatement
Bulkrax::Entry.prepend Extensions::Bulkrax::Entry::MultipleCheck
Bulkrax::CsvEntry.prepend Extensions::Bulkrax::Entry::DynamicSchemaField
Bulkrax::MetsXmlEntry.prepend Extensions::Bulkrax::Entry::DynamicSchemaField
Bulkrax::ObjectFactory.prepend Extensions::Bulkrax::ObjectFactory::CreateWithDynamicSchema
# feature change: merged configured/default mappings, instead of overridden
Bulkrax::Exporter.prepend Extensions::Bulkrax::Exporter::Mapping
Bulkrax::Importer.prepend Extensions::Bulkrax::Importer::Mapping
# feature change: drop forced capitalization of subject
Bulkrax::ApplicationMatcher.prepend Extensions::Bulkrax::ApplicationMatcher::ParseSubject
# bugfix: handle nil, single-valued properties getting converted to '[]'
Bulkrax::Entry.prepend Extensions::Bulkrax::Entry::SingleMetadata
# bugfix: recognize title_1 as valid instance of required title field for import
Bulkrax::ApplicationParser.prepend Extensions::Bulkrax::ApplicationParser::RequiredElementsWithIndex
Bulkrax::CsvParser.prepend Extensions::Bulkrax::CsvParser::MissingElementsWithIndex
# feature removal: drop support for files export
Bulkrax::Exporter.prepend Extensions::Bulkrax::Exporter::ExportMetadataOnly
# bugfix: accept depositor permissions for parent relationship
Bulkrax::CreateRelationshipsJob.prepend Extensions::Bulkrax::CreateRelationshipsJob::DepositorParentPermissions

### IIIF Print, quick and dirty way to get the FileSetActor to load after CreateWithFilesActor
Hyrax::Actors::FileSetActor.prepend(IiifPrint::Actors::FileSetActorDecorator)
Hyrax::Actors::FileSetOrderedMembersActor.prepend Extensions::Hyrax::Actors::FileSetOrderedMembersActor::PdfSplit

# actor customizations
Hyrax::CurationConcern.actor_factory.insert Hyrax::Actors::TransactionalRequest, ESSI::Actors::PerformLaterActor
Hyrax::CurationConcern.actor_factory.swap Hyrax::Actors::CreateWithRemoteFilesActor, ESSI::Actors::CreateWithRemoteFilesOrderedMembersStructureActor
Hyrax::CurationConcern.actor_factory.swap Hyrax::Actors::CreateWithFilesActor, Hyrax::Actors::CreateWithFilesOrderedMembersActor
Hyrax::Actors::BaseActor.prepend Extensions::Hyrax::Actors::BaseActor::UndoAttributeArrayWrap
Hyrax::Actors::FileSetActor.prepend Extensions::Hyrax::Actors::FileSetActor::CreateContent
Hyrax::Actors::ApplyOrderActor.prepend Extensions::Hyrax::Actors::ApplyOrderActor::AddMembersSingleSave

# .jp2 conversion settings
Hydra::Derivatives.kdu_compress_path = ESSI.config.dig(:essi, :kdu_compress_path)
Hydra::Derivatives.kdu_compress_recipes =
  Hydra::Derivatives.kdu_compress_recipes.with_indifferent_access
                    .merge(ESSI.config.dig(:essi, :jp2_recipes) || {})

# ocr derivation
Hyrax::DerivativeService.services.unshift ESSI::FileSetOCRDerivativesService

# add customized terms, currently just campus, to collection forms
Hyrax::Forms::CollectionForm.include Extensions::Hyrax::Forms::CollectionForm::CustomizedTerms
Hyrax::CollectionPresenter.include Extensions::Hyrax::CollectionPresenter::CustomizedTerms
AdminSet.include Extensions::Hyrax::AdminSet::CampusOnAdminSet
Hyrax::Forms::AdminSetForm.include Extensions::Hyrax::Forms::AdminSetForm::CustomizedTerms

# ESSI-1438 Large works cause solr URI Too Long error
# @todo method is moved after upgrade to Hyrax 3.x
Hyrax::GrantReadToMembersJob.prepend Extensions::Hyrax::Jobs::FileSetIdsPost
Hyrax::GrantEditToMembersJob.prepend Extensions::Hyrax::Jobs::FileSetIdsPost
Hyrax::RevokeEditFromMembersJob.prepend Extensions::Hyrax::Jobs::FileSetIdsPost

# Hyrax user lookup
Hyrax::UsersController.prepend Extensions::Hyrax::UsersController::FindUser

# Hyrax Work Type selection
Hyrax::SelectTypeListPresenter.prepend Extensions::Hyrax::SelectTypeListPresenter::OptionsForSelect

# return false for render_bookmarks_control? in CollectionsController
Hyrax::CollectionsController.prepend Extensions::Hyrax::CollectionsController::RenderBookmarksControl

# ESSI-1578: Add all searchable fields into the collection search builder context
Hyrax::CollectionsController.prepend Extensions::Hyrax::CollectionsController::ParamsForQuery
Hyrax::Dashboard::CollectionsController.prepend Extensions::Hyrax::Dashboard::CollectionsController::ParamsForQuery

# ESSI-1361: select from all files for Collection thumbnail
Hyrax::Forms::CollectionForm.prepend Extensions::Hyrax::Forms::CollectionForm::AllFilesWithAccess
Hyrax::CollectionMemberSearchBuilder.prepend Extensions::Hyrax::CollectionMemberSearchBuilder::Rows
Hyrax::Collections::CollectionMemberService.prepend Extensions::Hyrax::Collections::CollectionMemberService::AvailableMemberFilesetTitleIds

# ESSI-1337: apply custom renderers to catalog index, as well as on Show page
Blacklight::IndexPresenter.include ESSI::PresentsCustomRenderedAttributes

# Fix raw SQL queries
# @todo remove after upgrade to Hyrax 3.x
Hyrax::Collections::PermissionsService.include Extensions::Hyrax::Collections::PermissionsService::SourceIds

# Collections search
Qa::Authorities::Collections.prepend Extensions::Qa::Authorities::Collections::CollectionsSearch

# update obsolete URI escaping methods
Hydra::AccessControls::Permission.prepend Extensions::Hydra::AccessControls::Permission::EscapingObsoletions
ActiveFedora::File.prepend Extensions::ActiveFedora::File::EscapingObsoletions

# change total count methods to cover all descendants in the tree
Hyrax::CollectionPresenter.prepend Extensions::Hyrax::CollectionPresenter::TotalCounts

# Increase solr row limit
Hyrax::PresenterFactory.prepend Extensions::Hyrax::PresenterFactory::SolrRowLimit

# prevent double-display of description from flexible metadata
IIIFManifest::ManifestBuilder::RecordPropertyBuilder.prepend Extensions::IIIFManifest::ManifestBuilder::RecordPropertyBuilder::DynamicDescription

# s3 support for HCP
Seahorse::Client::NetHttp::Handler.prepend Extensions::Seahorse::Client::NetHttp::Handler::HeadersPatch

# read pre-supplied file characterization, if present
Hydra::Works::CharacterizationService.prepend Extensions::Hydra::Works::CharacterizationService::Precharacterization

# Patch ShellBasedProcessor to handle IO::EAGAINWaitReadable
Hydra::Derivatives::Processors::Jpeg2kImage.prepend Extensions::Hydra::Derivatives::Processors::WaitReadable

# Workarounds to make previous IIIF search-related Solr fields compatible with iiif_print until they are reindexed
IiifPrint::BlacklightIiifSearch::AnnotationDecorator.include Extensions::IiifPrint::BlacklightIiifSearch::AnnotationDecorator::AnnotationDecoratorCompatibility
IiifPrint::IiifSearchDecorator.include Extensions::IiifPrint::IiifSearchDecorator::SearchDecoratorCompatibility

# Patch iiif_print FileSet job calls
IiifPrint::Data.include Extensions::IiifPrint::Data::InheritPermissionsJobCalls

# Patch iiif_print manifest metadata
IiifPrint.include Extensions::IiifPrint::ManifestMetadata
IiifPrint::IiifManifestPresenterBehavior.include Extensions::IiifPrint::IiifManifestPresenterBehavior::ManifestMetadata
IiifPrint::Metadata.prepend Extensions::IiifPrint::Metadata::FacetedValuesForCampus

# Patch iiif_print for solr 9
IiifPrint::HighlightSearchParams.include Extensions::IiifPrint::HighlightSearchParams::HighlightSearchParamsCompatibility
IiifPrint::CatalogSearchBuilder.include Extensions::IiifPrint::CatalogSearchBuilder::SkipCollectionsFacetFiltering

# Patch iiif_print for broken is_child filtering
IiifPrint::CatalogSearchBuilder.prepend Extensions::IiifPrint::CatalogSearchBuilder::FixIsChildFiltering

# support for nested works generating file_set sequences in manifests
IIIFManifest::ManifestBuilder::DeepFileSetEnumerator.prepend Extensions::IIIFManifest::ManifestBuilder::DeepFileSetEnumerator::NestedEach

# support for memoizing the member_presenter_factory
Hyrax::WorkShowPresenter.prepend Extensions::Hyrax::WorkShowPresenter::MemberPresenterFactoryMemoization

# support for rendering an orphan FileSet
Hyrax::FileSetsController.prepend Extensions::Hyrax::FileSetsController::RenderOrphanFileSet

# support for FileSetPresenter#content_location
Hyrax::FileSetPresenter.include Extensions::Hyrax::FileSetPresenter::ContentLocation
