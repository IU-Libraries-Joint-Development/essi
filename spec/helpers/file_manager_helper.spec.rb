require 'rails_helper'

describe FileManagerHelper do

  describe '#ocr_check(:id)' do
    x_mark = '❌'
    check_mark = '✅'
    context 'when fileset does not have extracted text' do
      it 'returns an X mark' do
        mock_fileset = double('FileSet', extracted_text: nil)
        allow(FileSet).to receive(:find).with('123abc').and_return(mock_fileset)
        expect(helper.ocr_check('123abc')).to eq(x_mark)
      end
    end
    context 'when fileset does have extracted text' do
      it 'returns a check mark' do
        mock_fileset = double('FileSet', extracted_text: 'Something')
        allow(FileSet).to receive(:find).with('987zyx').and_return(mock_fileset)
        expect(helper.ocr_check('987zyx')).to eq(check_mark)
      end
    end
  end
end
