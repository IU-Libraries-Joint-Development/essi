# frozen_string_literal: true

require 'rails_helper'

module Bulkrax
  RSpec.describe MetsXmlEntry, type: :model do
    let(:path) { './spec/fixtures/xml/METADATA.xml' }
    let(:data) { described_class.read_data(path) }
    let(:data_for_entry) { described_class.entry_formatted_xml(data) }
    let(:source_identifier) { :OBJID }
    let(:mappings) do
     {
        'source_identifier' => { from: [source_identifier.to_s], source_identifier: true, split: false }.with_indifferent_access
      }.with_indifferent_access
    end
    let(:importer) do
      i = FactoryBot.create(:bulkrax_importer_mets_xml)
      i.field_mapping['source_identifier'] = mappings['source_identifier']
      i.current_run
      i
    end

    around do |spec|
      original_mappings = Bulkrax.field_mappings['Bulkrax::XmlParser']
      Bulkrax.field_mappings['Bulkrax::XmlParser'] = mappings

      spec.run
      if original_mappings.nil?
        Bulkrax.field_mappings.delete('Bulkrax::XmlParser')
      else
        Bulkrax.field_mappings['Bulkrax::XmlParser'] = original_mappings
      end
    end

    describe 'class methods' do
      context '#read_data' do
        it 'reads the data from an xml file' do
          expect(described_class.read_data(path)).to be_a(Nokogiri::XML::Document)
        end
      end

      context '#data_for_entry' do
        it 'retrieves the data and constructs a hash' do
          expect(described_class.data_for_entry(data.root, source_identifier, nil)).to eq(
            OBJID: 'http://purl.dlib.indiana.edu/iudl/archives/VAC1741-00310',
            delete: nil,
            data: data_for_entry,
            collection: [],
            children: []
          )
        end
      end
    end

    describe 'deleted' do
      let(:path) { './spec/fixtures/xml/deleted.xml' }
      let(:raw_metadata) { described_class.data_for_entry(data.root, source_identifier, nil) }

      it 'parses the delete as true if present' do
        expect(raw_metadata[:delete]).to be_truthy
      end
    end

    describe '#build' do
      subject(:xml_entry) { described_class.new(importerexporter: importer) }
      let(:raw_metadata) { described_class.data_for_entry(data.root, source_identifier, nil) }
      let(:object_factory) { instance_double(ObjectFactory) }

      before do
        Bulkrax.default_work_type = 'PagedResource' # change?
      end

      it 'parses the delete as nil if it is not present' do
        expect(raw_metadata[:delete]).to be_nil
      end

      context 'with raw_metadata' do
        before do
          xml_entry.raw_metadata = raw_metadata
          allow(ObjectFactory).to receive(:new).and_return(object_factory)
          allow(object_factory).to receive(:run!).and_return(instance_of(PagedResource))
          allow(User).to receive(:batch_user)
          VCR.use_cassette('mets_xml_entry_spec') do
            xml_entry.build
          end
        end

        it 'succeeds' do
          expect(xml_entry.status).to eq('Complete')
        end

        it 'adds logical structure' do
          logical_structure = xml_entry.parsed_metadata['structure'].with_indifferent_access
          node = logical_structure['nodes'].first
          expect(node['label']).to eq('page 3')
          expect(node['nodes'].first['proxy']).to eq('VAC1741-U-00064-003-thumbnail')
        end

        let(:parsed_metadata) { YAML.load_file('spec/fixtures/vcr_cassettes/parsed_metadata.yml') }
        it 'parses metadata' do
          expect(xml_entry.parsed_metadata).to eq parsed_metadata
        end
      end

      context 'without raw_metadata' do
        before do
          xml_entry.raw_metadata = nil
          allow(ObjectFactory).to receive(:new).and_return(object_factory)
          allow(object_factory).to receive(:run!).and_return(instance_of(PagedResource))
          allow(User).to receive(:batch_user)
          VCR.use_cassette('mets_xml_entry_spec') do
            xml_entry.build
          end
        end

        it 'fails' do
          expect(xml_entry.status).to eq('Failed')
        end
      end
    end
  end
end
