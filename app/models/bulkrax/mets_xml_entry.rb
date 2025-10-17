# frozen_string_literal: true

require 'nokogiri'
module Bulkrax
  class MetsXmlEntry < XmlEntry
    # MetsXmlEntry method overrides (pending)
    #

    # unmodified from XmlEntry
    # @param [String] path
    # @return [Nokogiri::XML::Document]
    def self.read_data(path)
      # This doesn't cope with BOM sequences:
      # Nokogiri::XML(open(path), nil, 'UTF-8').remove_namespaces!
      Nokogiri::XML(open(path)).remove_namespaces!
    end

    # unmodified from XmlEntry
    # @param [Nokogiri::XML::Element] data
    # @param [Symbol] source_id
    # @param [Bulkrax::MetsXMLParser] _parser
    # @return Hash
    def self.data_for_entry(data, source_id, _parser)
      collections = []
      children = []
      xpath_for_source_id = ".//*[name()='#{source_id}']"
      return {
        source_id => data.xpath(xpath_for_source_id).first.text,
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

    # unmodified from XmlEntry
    # @return Nokogiri::XML
    def record
      @record ||= Nokogiri::XML(self.raw_metadata['data'], nil, 'UTF-8')
    end

    # unmodified from XmlEntry
    def establish_factory_class
      model_field_names = parser.model_field_mappings

      each_candidate_metadata_node_name_and_content(elements: parser.model_field_mappings) do |name, content|
        next unless model_field_names.include?(name)
        add_metadata(name, content)
      end
    end

    # unmodified from XmlEntry
    # @param Array elements
    def each_candidate_metadata_node_name_and_content(elements: field_mapping_from_values_for_xml_element_names)
      elements.each do |name|
        # NOTE: the XML element name's case matters
        nodes = record.xpath("//*[name()='#{name}']")
        next if nodes.empty?

        nodes.each do |node|
          node.children.each do |content|
            next if content.to_s.blank?

            yield(name, content.to_s)
          end
        end
      end
    end

    # unmodifed from HasLocalProcessing module
    def add_local; end

    # unmodified from ImportBehavior
    def find_collection_ids
      self.collection_ids
    end

    # MetsXmlEntry new methods
    #
  end
end
