module FileSetPresenterAddViewingHints
  delegate :viewing_hint, to: :solr_document
  #@todo remove after upgrade to Hyrax 3.x
  delegate :original_file_id, to: :solr_document
end

Hyrax::FileSetPresenter.class_eval do
  prepend FileSetPresenterAddViewingHints
end

module ImageBuilderAddViewingHints
  def apply(canvas)
    canvas['viewingHint'] = canvas_viewing_hint(canvas)
    super
  end

  def canvas_viewing_hint(canvas)
    id = canvas['@id'].split('/').last
    FileSet.search_with_conditions({ id: id }, rows: 1)&.first['viewing_hint_tesim']&.first
  end
end

IIIFManifest::ManifestBuilder::ImageBuilder.class_eval do
  prepend ImageBuilderAddViewingHints
end
