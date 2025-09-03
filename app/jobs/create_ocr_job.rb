class CreateOCRJob < CreateDerivativesJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    return if file_set.video? && !Hyrax.config.enable_ffmpeg

    unless filepath && File.exist?(filepath)
      if file_set.content_location&.start_with?('s3://') # Ensure external file is available locally
        ext_id = file_set.content_location.split('/').last
        ext_resp = ESSI.external_storage.get(ext_id)
        filepath = Hyrax::WorkingDirectory.send(:copy_stream_to_working_directory, ext_id, ext_id, ext_resp.body)
      else
        filepath = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id)
      end
    end

    # using #create_derivatives instead of #create_ocr_derivatives to use IIIF Print
    # @see https://github.com/scientist-softserv/iiif_print/blob/d14246664048c708071c7ff4de2e9a34aa703465/app/services/iiif_print/pluggable_derivative_service.rb#L25
    file_set.send(:file_set_derivatives_service).send(:create_derivatives, filepath)

    # Reload from Fedora and reindex for thumbnail and extracted text
    file_set.reload
    file_set.update_index
    file_set.parent.update_index if parent_needs_reindex?(file_set)
  end
end
