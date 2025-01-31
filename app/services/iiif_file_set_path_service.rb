class IIIFFileSetPathService
  attr_reader :file_set, :versioned_lookup

  # @param [ActiveFedora::SolrHit, FileSet, Hash, SolrDocument, Hyrax::FileSetPresenter] file_set
  # @param [TrueClass, FalseClass, NilClass] versioned_lookup: whether to use versioned file lookup if original_file_id fails
  def initialize(file_set, versioned_lookup: false)
    @versioned_lookup = versioned_lookup
    file_set = SolrDocument.new(file_set) if file_set.class.in? [ActiveFedora::SolrHit, Hash]
    if [:id, :content_location, :original_file_id].map { |m| file_set.respond_to?(m) }.all?
      @file_set = file_set
    else
      raise StandardError, 'Provided file_set does not meet interface requirements' 
    end
  end

  def lookup_id
    @lookup_id ||= (@versioned_lookup ? versioned_lookup_id : basic_lookup_id)
  end

  # @return [String] a URL that resolves to an image provided by a IIIF image server
  def iiif_image_url(base_url: nil, size: nil)
    return unless lookup_id
    Hyrax.config.iiif_image_url_builder.call(lookup_id, base_url, size || Hyrax.config.iiif_image_size_default)
  end

  # @return [String] a URL that resolves to an info.json file provided by a IIIF image server
  def iiif_info_url(base_url)
    return unless lookup_id
    Hyrax.config.iiif_info_url_builder.call(lookup_id, base_url)
  end

  private
    # imported logic from IIIFThumbnailPathService, etc
    def basic_lookup_id
      @basic_lookup_id ||= (file_set.content_location || file_set.original_file_id)
    end

    # imported from Hyrax::DisplaysImage
    def versioned_lookup_id
      @versioned_lookup_id ||= begin
        result = basic_lookup_id
        if result.blank?
          Rails.logger.warn "original_file_id for #{file_set.id} not found, falling back to Fedora."
          # result = Hyrax::VersioningService.versioned_file_id(original_file)
          result = versioned_file_id(original_file) if original_file

        end
        if result.blank?
          Rails.logger.warn "original_file for #{file_set.id} not found, versioned_lookup_id failed."
          nil
        else
          result
        end
      end
    end

    # @return [Hydra::PCDM::File, nil]
    def original_file
      @original_file ||= 
        case file_set
        when FileSet
          file_set.original_file
        else
          begin
            FileSet.find(file_set.id).original_file
          rescue => error
            Rails.logger.error "original_file lookup for #{file_set.id} raised error: #{error.inspect}"
            nil
          end
        end
    end

    # @todo remove after upgrade to Hyrax 3.x
    # cherry-picked from Hyrax 3.x VersioningService
    # @param [ActiveFedora::File | Hyrax::FileMetadata] content
    def versioned_file_id(file)
      @versioned_file_id ||= begin
        raise StandardError, 'No original_file available for versioning' if file.nil?
        versions = file.versions.all
        if versions.present?
          ActiveFedora::File.uri_to_id versions.last.uri
        else
          file.id
        end
      end
    end
end
