module IuMetadata
  class METSRecord < METSDocument
    def initialize(id, source)
      @id = id
      @source = source
      @mets = Nokogiri::XML(source)
    end

    attr_reader :id, :source

    # local metadata; can be overriden by descriptive metadata
    ATTRIBUTES = %w[
      identifier
      purl
      related_url
      series
      source_metadata_identifier
      title
      viewing_direction
    ].freeze

    def attributes
      @attributes ||= local_metadata.merge(descriptive_metadata).with_indifferent_access
    end

    def local_metadata
      ATTRIBUTES.map { |att| [att, send(att)] }.to_h.compact
    end

    def descriptive_metadata
      { description: description,
        date_created: date_created,
        creator: creator,
        genre: genre,
        publisher: publisher,
        language: language,
        source: source,
        subject: subject,
        title: wrapped_metadata('dc:title'), # overrides title
        related_url: wrapped_metadata('dcterms:relation') # overrides related_url
      }
    end

    def identifier
      obj_id
    end
    # deprecation planned for purl
    alias_method :purl, :identifier

    def source_metadata_identifier
      mets_id
    end

    def source
      [source_metadata_identifier]
    end

    def title
      Array.wrap([label, mets_id].select(&:present?).first)
    end

    # no default metadata

    # ingest metadata
    def volumes
      volumes = []
      volume_ids.each do |volume_id|
        volume_hash = {}
        volume_hash[:title] = [label_for_volume(volume_id)]
        volume_hash[:structure] = structure_for_volume(volume_id)
        volume_hash[:files] = files_for_volume(volume_id)
        volumes << volume_hash
      end
      volumes
    end

    def files
      add_file_attributes super
    end

    def collections
      Array.wrap(collection_slugs)
    end

    private

      def add_file_attributes(file_hash_array)
        file_hash_array.each do |f|
          f[:file_opts] = file_opts(f)
          f[:attributes] ||= {}
          f[:attributes][:title] = [file_label(f[:id])]
        end
        file_hash_array
      end

      def files_for_volume(volume_id)
        add_file_attributes super
      end
  end
end
