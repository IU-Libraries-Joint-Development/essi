require 'rails_helper'

RSpec.describe Qa::Authorities::IucatLibraries do
  let(:authority) { described_class.new }
  let(:matching_id) { 'B-WELLS' }
  let(:nonmatching_id) { 'foobar' }

  context 'when configuration does not exist' do
    describe '#all' do
      let(:result) { authority.all }
      it 'returns an empty Array' do
        allow(ESSI.config).to receive(:[]).with(:iucat_libraries).and_return(nil)
        expect(result).to be_a Array
        expect(result).to be_empty
      end
    end
  end

  context 'with server response', vcr: { cassette_name: 'iucat_libraries_up', record: :new_episodes } do
    describe '#all' do
      let(:result) { authority.all }
      it 'returns a populated Array' do
        expect(result).to be_a Array
        expect(result).not_to be_empty
      end
    end

    describe '#find' do
      context 'with a matching id' do
        let(:result) { authority.find(matching_id) }
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
    end

    describe '#search' do
      context 'with a matching id' do
        let(:result) { authority.search(matching_id) }
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
  end
end
