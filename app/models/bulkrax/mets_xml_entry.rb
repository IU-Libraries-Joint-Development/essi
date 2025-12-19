# frozen_string_literal: true

require 'nokogiri'
module Bulkrax
  class MetsXmlEntry < XmlEntry
    # MetsXmlEntry method overrides
    #

    # modified from XmlEntry: don't remove namespaces
    # @param [String] path
    # @return [Nokogiri::XML::Document]
    def self.read_data(path)
      Nokogiri::XML(open(path))
    end

    # modified from XmlEntry for source_id value sourcing
    # @param [Nokogiri::XML::Element] data
    # @param [Symbol] source_id
    # @param [Bulkrax::MetsXMLParser] _parser
    # @return Hash
    def self.data_for_entry(data, source_id, _parser)
      collections = []
      children = []
     
      return {
        source_id => data.attributes.with_indifferent_access[source_id].text,
        delete: data.xpath(".//*[name()='delete']").first&.text,
        data:
          data.to_xml(
            encoding: 'UTF-8',
            save_with:
              Nokogiri::XML::Node::SaveOptions::NO_DECLARATION | Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS
          ).delete("\n").delete("\t").squeeze(' '), # Remove newlines, tabs, and extra whitespace
        collection: collections,
        children: children
      }
    end

    # modified from XmlEntry
    # uses mets instead of xml for record
    # @return IuMetata::METSRecord
    def record
      @record ||= IuMetadata::METSRecord.new(source_identifier_value, raw_metadata['data'])
    end

    # modified from XmlEntry
    # sources model from importer form, rather than imported record
    def establish_factory_class
      self.parsed_metadata['model'] = parser.parser_fields['work_type'] || 'PagedResource'
    end

    # modified from XmlEntry
    # uses IuMetatata::METSRecord for sourcing,
    # elements defaults to all available attributes
    # @param Array elements
    def each_candidate_metadata_node_name_and_content(elements: record.attributes.keys)
      record.attributes.select { |k,v| k.in?(elements) }.each do |k,v|
        yield(k,v)
      end
    end

    # MetsXmlEntry overrides of inherited methods
    #

    # modifed from HasLocalProcessing module
    # adds mets-specific metadata handling
    def add_local
      add_local_files
      add_remote_files
      add_title
      add_logical_structure
      add_parents
      add_form_values
    end

    # modified from ImportBehavior
    # gets single collection_id, if any, from importer form
    def find_collection_ids
      if parser.parser_fields['collection_id'].present?
        self.collection_ids = Array.wrap(parser.parser_fields['collection_id'])
      else
        self.collection_ids = []
      end
      self.collection_ids
    end

    # MetsXmlEntry new methods
    #

    def source_identifier_value
      @source_identifier_value ||= self.raw_metadata[source_identifier]
    end

    # memoize to handle url redirections just once
    def files
      @files ||= record.files
    end

    def add_local_files
      local_files = files.reject { |e| e[:url].match(URI::ABS_URI) }.map { |e| e[:url] }
      self.parsed_metadata['file'] = local_files if local_files.any?
    end

    def add_remote_files
      remote_files = files.select { |e| e[:url].match(URI::ABS_URI) }
      self.parsed_metadata['remote_files'] = remote_files if remote_files.any?
    end

    def add_logical_structure
      self.parsed_metadata['structure'] = record.structure 
    end

    def add_parents
      self.parsed_metadata['parents'] = collection_ids     
    end

    def override_title?
      %w[true 1].include?(parser.parser_fields['override_title'].to_s)
    end

    def add_title
      self.parsed_metadata['title'] = [parser.parser_fields['title']] if override_title? || self.parsed_metadata['title'].blank?
    end

    def add_form_values
      ['campus', 'pdf_state', 'ocr_state'].each do |term|
        value = parser.parser_fields[term]
        value = Array.wrap(value) if factory_class.properties.with_indifferent_access[term]&.multiple?
        self.parsed_metadata[term] = value
      end
    end
  end
end
