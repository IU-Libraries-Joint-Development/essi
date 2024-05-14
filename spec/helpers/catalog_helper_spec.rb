require 'rails_helper'

describe CatalogHelper do
  describe '#thumbnail_url(:document)' do
    subject { helper.thumbnail_url(work_document) }

    context 'when the document exists' do
      let(:work_document) { SolrDocument.new(id: work_id, hasRelatedImage_ssim: thumbnail_id) }
      let(:fileset_document) { SolrDocument.new(id: fileset_id,
                                                original_file_id_ssi: original_file_id,
                                                content_location_ssi: content_location) }
      let(:work_id) { 'test0001'}
      let(:fileset_id) { 'abcd1234' }
      let(:original_file_id) { nil }
      let(:thumbnail_id) { [] }
      let(:content_location) { nil }

      context 'with a thumbnail_id' do
        let(:thumbnail_id) { ['abcd1234'] }
        before do
          allow(SolrDocument).to receive(:find).with(fileset_id).and_return(fileset_document)
        end

        context 'with an original_file_id' do
          let(:original_file_id) { 'abcd1234/files/zyxw0987' }
          it { is_expected.to match '/iiif/2/abcd1234%2Ffiles%2Fzyxw0987/full/250,/0/default.jpg' }
        end

        context 'with an s3 content_location' do
          let(:content_location) { 's3://essi-test/ext-store/ab/cd/12/34/abcd1234-original_file.jp2' }
          it { is_expected.to match '/iiif/2/s3:%2F%2Fessi-test%2Fext-store%2Fab%2Fcd%2F12%2F34%2Fabcd1234-original_file.jp2/full/250,/0/default.jpg' }
        end

        context 'without an original_file_id' do
          it { is_expected.to eq helper.image_path 'default.png' }
        end
      end

      context 'without a thumbnail_id' do
        it { is_expected.to eq helper.image_path 'default.png' }
      end
    end

    context 'when the document does not exist' do
      let(:work_document) { nil }
      it { is_expected.to eq helper.image_path 'default.png' }
    end
  end
end
