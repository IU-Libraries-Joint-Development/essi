require 'rails_helper'

describe LockWarningHelper do

  describe '#lock_arning(curation_concern)' do
    context 'when the concern is not locked' do
      it 'returns nil' do
        mock_concern = double('PagedResource')
        allow(mock_concern).to receive(:lock?).and_return(false)
        expect(helper.lock_warning(mock_concern)).to be_nil
      end
    end
    context 'when fileset does have extracted text' do
      it 'returns an alert String' do
        mock_concern = double('PagedResource')
        allow(mock_concern).to receive(:lock?).and_return(true)
        expect(helper.lock_warning(mock_concern)).to be_a String
      end
    end
  end
end
