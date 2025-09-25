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

  let(:file_set) { FactoryBot.build(:file_set) }
  let(:external_id) { "s3_id" }
  let(:external_location) { "s3://#{external_id}" }
  describe "#external?" do
    context "when stored in S3" do
      before { allow(file_set).to receive(:content_location).and_return(external_location) }
      it "returns true" do
        expect(service.external?(file_set)).to eq true
      end
    end
    context "when stored in Fedora" do
      it "returns false" do
        expect(service.external?(file_set)).to eq false
      end
    end
  end

  describe "#external_id" do
    context "when stored in S3" do
      before { allow(file_set).to receive(:content_location).and_return(external_location) }
      it "returns the S3 internal id" do
        expect(service.external_id(file_set)).to eq external_id
      end
    end
    context "when stored in Fedora" do
      it "returns nil" do
        expect(file_set.external_id).to be_nil
      end
    end
  end

  describe "#find_or_retrieve" do
    shared_examples "find_or_retrieve examples" do |argument_filepath|
      context "when file is stored in S3" do
        let(:output_filepath) { 'filepath_from_s3' }
        before do
          allow(file_set).to receive(:content_location).and_return("s3://server/external_id")
          allow(service).to receive(:get).and_return(double(body: nil))
          allow(Hyrax::WorkingDirectory).to receive(:copy_stream_to_working_directory).and_return(output_filepath)
        end
        it "retrieves external file content" do
          expect(service).to receive(:get)
          service.find_or_retrieve(file_set, filepath: argument_filepath)
        end
        it "copies stream to working directory" do
          expect(Hyrax::WorkingDirectory).to receive(:copy_stream_to_working_directory)
          service.find_or_retrieve(file_set, filepath: argument_filepath)
        end
        it "returns filepath" do
          expect(service.find_or_retrieve(file_set, filepath: argument_filepath)).to eq output_filepath
        end
      end
      context "when file is stored in Fedora" do
        it "logs warning" do
          expect(Rails.logger).to receive(:warn)
          service.find_or_retrieve(file_set, filepath: argument_filepath)
        end
        it "returns nil" do
          expect(service.find_or_retrieve(file_set, filepath: argument_filepath)).to be_nil
        end
      end
    end
    context "when filepath provided" do
      let(:argument_filepath) { '/tmp/existing_file.txt' }
      context "when file present" do
        before { allow(File).to receive(:exist?).with(argument_filepath).and_return(true) }
        it "returns the filepath" do
          expect(service.find_or_retrieve(file_set, filepath: argument_filepath)).to eq argument_filepath
        end
      end
      context "when file absent" do
        include_examples "find_or_retrieve examples", '/tmp/existing_file.txt'
      end
    end
    context "when filepath not provided" do
      include_examples "find_or_retrieve examples", nil
    end
  end
end
