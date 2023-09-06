require 'rails_helper'

RSpec.describe ESSI::ExternalStorageService do
  let(:service) { described_class.new }
  let(:id) { 'essi-ext-store-spec' }
  let(:file) { File.open(RSpec.configuration.fixture_path + "/fulltext.txt") }
  let(:content_type) {'text/plain'}
  let(:metadata) { { "original-filename" => Pathname.new(file).basename.to_s } }

  before do
    allow(service).to receive(:endpoint).and_return('http://minio:9000')
  end

  context 'with minio VCR', vcr: { cassette_name: 'external_storage_minio' } do
    it 'performs file CRUD' do
      expect(service.list.contents).to_not include(have_attributes(key: service.prefix_id(id)))
      expect(service.put(id, file, content_type: content_type, params: { metadata: metadata })).to be_successful
      expect(service.list.contents).to include(have_attributes(key: service.prefix_id(id)))
      expect(service.head(id)).to have_attributes(content_type: content_type, metadata: metadata)
      file.rewind
      expect(service.get(id).body.read).to eq(file.read)
      expect(service.delete(id)).to be_successful
      expect(service.list.contents).to_not include(have_attributes(key: service.prefix_id(id)))
    end
  end


  describe '#id_to_http_uri' do
    it 'returns an http uri' do
      expect(service.id_to_http_uri(id)).to eq('http://minio:9000/essi-test/ext-store/es/si/-e/xt/essi-ext-store-spec')
    end
  end

  describe '#id_to_s3_uri' do
    it 'returns an s3:// uri' do
      expect(service.id_to_s3_uri(id)).to eq('s3://essi-test/ext-store/es/si/-e/xt/essi-ext-store-spec')
    end
  end

  describe '#prefix_id' do
    it 'prefixes the id with the prefix and a pairtree' do
      expect(service.prefix_id(id)).to eq('ext-store/es/si/-e/xt/essi-ext-store-spec')
    end
  end
end
