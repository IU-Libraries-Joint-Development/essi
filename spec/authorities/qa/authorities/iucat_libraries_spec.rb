require 'rails_helper'

RSpec.describe Qa::Authorities::IucatLibraries do
  let(:authority) { described_class.new }
  let(:supplemental_filepath) { File.join(fixture_path, 'authorities', 'supplemental_holding_locations.yml') }
  let(:holding_location_filepath) { File.join(fixture_path, 'authorities', 'holding_locations.yml') }
  let(:supplemental_data) { authority.send(:supplemental_data) }
  let(:holding_location_data) { authority.send(:holding_location_data) }
  let(:matching_id) { 'B-WELLS' }
  let(:supplemental_id) { 'B-MEDIASCHOOL' }
  let(:nonmatching_id) { 'foobar' }
  let(:invalid_id) { 'B-WELLS and more' }

  before do
    allow(authority).to receive(:holding_location_filepath).and_return(holding_location_filepath)
    allow(authority).to receive(:supplemental_filepath).and_return(supplemental_filepath)
  end

  describe '#all' do
    let(:result) { authority.all }
    it 'returns the combined set of holding location and supplemental data' do
      expect(result).to be_a Array
      expect(result).not_to be_empty
      expect(result.size).to eq holding_location_data.size + supplemental_data.size
    end
  end

  describe '#find' do
    context 'with a matching id in the API' do
      let(:result) { authority.find(matching_id) }
      it 'returns a Hash' do
        expect(result).to be_a Hash
        expect(result).not_to be_empty
      end
    end
    context 'with a matching id in the supplemental data' do
      let(:result) { authority.find(supplemental_id) }
      it 'returns a Hash' do
        expect(result).to be_a Hash
        expect(result).not_to be_empty
      end
    end
    context 'with a non-matching id' do
      let(:result) { authority.find(nonmatching_id) }
      it 'returns an empty Hash' do
        expect(result).to be_a Hash
        expect(result).to be_empty
      end
    end
    context 'with an invalid id' do
      let(:result) { authority.find(invalid_id) }
      it 'returns an empty Hash' do
        expect(result).to be_a Hash
        expect(result).to be_empty
      end
    end
  end

  describe '#search' do
    context 'with a matching id in the API ' do
      let(:result) { authority.search(matching_id) }
      it 'returns a populated Array' do
        expect(result).to be_a Array
        expect(result).not_to be_empty
      end
    end
    context 'with a matching id in the supplemental data ' do
      let(:result) { authority.search(supplemental_id) }
      it 'returns a populated Array' do
        expect(result).to be_a Array
        expect(result).not_to be_empty
      end
    end
    context 'with a non-matching id' do
      let(:result) { authority.search(nonmatching_id) }
      it 'returns an empty Array' do
        expect(result).to be_a Array
        expect(result).to be_empty
      end
    end
  end

  describe 'reload_data!' do
    let(:api_enabled) { { url: 'https://iucat.iu.edu/api/library',
                         api_enabled: true } }
    let(:api_disabled) { { url: 'http://some_unreachable_server',
                         api_enabled: false } }
    let(:temp_holding_location_filepath) { Tempfile.create.path }
    let(:temp_supplemental_filepath) { Tempfile.create.path }
    let(:api_config) { nil }

    before do
      FileUtils.cp holding_location_filepath, temp_holding_location_filepath
      allow(authority).to receive(:holding_location_filepath).and_return(temp_holding_location_filepath)
      FileUtils.cp supplemental_filepath, temp_supplemental_filepath
      allow(authority).to receive(:supplemental_filepath).and_return(temp_supplemental_filepath)
      allow(ESSI.config).to receive(:[]).with(:iucat_libraries).and_return(api_config)
      expect(authority).to receive(:reload_data_from_api!).and_call_original
    end

    after do
      FileUtils.rm_f temp_holding_location_filepath
      FileUtils.rm_f temp_supplemental_filepath
    end

    it 'reloads supplemental data' do
      expect(authority.send(:supplemental_data).size).to eq 8
      FileUtils.rm temp_supplemental_filepath
      expect { authority.reload_data! }.to change { authority.send(:supplemental_data) }.to([])
      expect(authority.send(:supplemental_data).size).to eq 0
    end

    context 'reloading holding location data' do
      context 'when configuration does not exist' do
        let(:api_config) { nil }

        it 'does not change the holding location data' do
          expect(authority.send(:holding_location_data).size).to eq 42
          expect { authority.reload_data! }.not_to change { authority.send(:holding_location_data) }
          expect(authority.send(:holding_location_data).size).to eq 42
        end
      end

      context 'when api is disabled' do
        let(:api_config) { api_disabled }

        it 'does not change the holding location data' do
          expect(authority.send(:holding_location_data).size).to eq 42
          expect { authority.reload_data! }.not_to change { authority.send(:holding_location_data) }
          expect(authority.send(:holding_location_data).size).to eq 42
        end
      end

      context 'when api is enabled', vcr: { cassette_name: 'iucat_libraries_up', record: :new_episodes } do
        let(:api_config) { api_enabled }

        it 'reloads the holding location data' do
          FileUtils.rm temp_holding_location_filepath
          expect(authority.send(:holding_location_data).size).to eq 0
          expect { authority.reload_data! }.to change { authority.send(:holding_location_data) }.from([])
          expect(authority.send(:holding_location_data).size).to eq 42
        end
      end
    end
  end
end
