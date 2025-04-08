# frozen_string_literal: true

require 'rails_helper'

module Bulkrax
  RSpec.describe Importer, type: :model do
    let(:importer) do
      FactoryBot.build(:bulkrax_importer_mets_xml)
    end
    let(:importer_runs) do
      FactoryBot.build_list(:bulkrax_importer_run, 2, importer: importer)
    end

    describe '#last_run', :clean do
      context 'with importer_runs' do
        before do
          allow(importer).to receive(:importer_runs).and_return(importer_runs)
        end
        it 'returns importer_runs.last' do
          expect(importer.last_run).to eq importer_runs.last
        end
      end
      context 'without importer_runs' do
        before do
          allow(importer).to receive(:importer_runs).and_return(Bulkrax::ImporterRun.none)
        end
        it 'returns nil' do
          expect(importer.last_run).to be_nil
        end
      end
    end

    describe '#mapping', :clean do
      context 'without a field_mapping' do
        before do
          allow(importer).to receive(:field_mapping).and_return(nil)
        end
        it 'returns default_mapping' do
          expect(importer.mapping).to eq importer.default_mapping
        end
      end
      context 'with a field_mapping' do
        before do
          allow(importer).to receive(:field_mapping).and_return({ test: { from:['test'] } })
        end
        it 'merges field_mapping into default_mapping' do
          expect(importer.mapping.keys).to include('test')
        end
      end
      context 'configuring witholding split' do
        let(:import_fields) { ['source_identifier'] }
        before do
          allow(importer.parser).to receive(:import_fields).and_return(import_fields)
          allow(importer).to receive(:field_mapping).and_return({ source_identifier: { split: false } })
        end
        it 'assigns split: false' do
          expect(importer.mapping[:source_identifier][:split]).to eq false
        end
      end
      context 'without specifying a split value' do
        let(:import_fields) { ['source_identifier'] }
        before do
          allow(importer.parser).to receive(:import_fields).and_return(import_fields)
        end
        it 'assumes splitting on : and |' do
          expect(importer.mapping[:source_identifier][:split]).to eq /\s*[;|]\s*/
        end
      end
    end
  
    describe '#default_mapping' do
      let(:import_fields) { ['title', 'description'] }
      before do
        allow(importer.parser).to receive(:import_fields).and_return(import_fields)
      end
      it 'returns a configuration for each import field' do
        expect(importer.default_mapping.size).to eq import_fields.size
        expect(importer.default_mapping.values.all?(ActiveSupport::HashWithIndifferentAccess)).to eq true
      end
    end
  end
end
