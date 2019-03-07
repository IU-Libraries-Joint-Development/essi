require 'rails_helper'

RSpec.describe PagedResourceIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(file_set) }
  let(:work) { FactoryBot.create(:paged_resource) }

  context 'with a file' do
    let(:work) { FactoryBot.create(:paged_resource_with_one_image) }
    let(:file_set) { work.file_sets.first}
    let(:file) { file_set.files.first }

    it 'indexes a IIIF thumbnail path' do
      expect(solr_document.fetch('thumbnail_path_ss')).to eq "http://localhost:3000/images/#{CGI.escape(file.id)}/full/250,/0/default.jpg"
    end
  end
end
