# frozen_string_literal: true

require 'rails_helper'

module Bulkrax
  RSpec.describe MetsXmlParser do
    let(:importer) { create(:bulkrax_importer_mets_xml) }
    subject(:xml_parser) { described_class.new(importer) }

    describe '#entry_class' do
      it 'returns Bulkrax::MetsXmlEntry' do
        expect(subject.entry_class).to eq Bulkrax::MetsXmlEntry
      end
    end

    describe '#create_relationships' do
      before do
        allow(subject).to receive(:parser_fields).and_return(parser_fields.with_indifferent_access)
        allow(ScheduleRelationshipsJob).to receive(:set).and_return(double('PerformLater', perform_later: true))
      end
      context 'with no collection_id' do
        let(:parser_fields) { {} }
        it 'does not call ScheduleRelationshipsJob' do
          expect(ScheduleRelationshipsJob).not_to receive(:set)
          subject.create_relationships
        end
      end
      context 'with a collection_id' do
        let(:parser_fields) { { collection_id: 'cid' } }
        it 'calls ScheduleRelationshipJob' do
          expect(ScheduleRelationshipsJob).to receive(:set)
          subject.create_relationships
        end
      end
    end
  end
end
