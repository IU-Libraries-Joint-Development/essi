require 'rails_helper'

RSpec.describe Tesseract do
  let(:languages) { { eng: 'English',
                      ita: 'Italian',
                      banana: 'banana',
                      rfccode: 'Translated' }.with_indifferent_access }

  describe '#languages' do
    before do
      allow(described_class).to receive(:language_output) \
        .and_return("List of available languages (107):" \
                    "\neng\nita\nbanana\nrfccode")
      allow(ISO_639).to receive(:find_by_code).and_call_original
      rfc_stub = instance_double('RFC Result', english_name: 'Translated')
      allow(ISO_639).to receive(:find_by_code).with('rfccode') \
                                              .and_return(rfc_stub)
    end
    it 'lists all available languages' do
      expect(described_class.languages).to eq languages
    end
  end

  describe '#try_languages' do
    before do
      allow(described_class).to receive(:languages).and_return(languages)
    end
    context 'with empty input' do
      it 'returns an empty String' do
        expect(described_class.try_languages(nil)).to eq ''
        expect(described_class.try_languages('')).to eq ''
      end
    end
    context 'with a single invalid value' do
      it 'returns an empty String' do
        expect(described_class.try_languages('foo')).to eq ''
      end
    end
    context 'with a single valid value' do
      it 'returns the string' do
        expect(described_class.try_languages('eng')).to eq 'eng'
      end
    end
    context 'with multiples values' do
      it 'filters and joins by +' do
        expect(described_class.try_languages(['eng', 'foo', 'ita'])).to eq 'eng+ita'
      end
    end
  end
end
