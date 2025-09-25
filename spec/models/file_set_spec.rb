require 'rails_helper'

RSpec.describe FileSet do
  let(:file_set) { FactoryBot.build(:file_set) }
  let(:collection_branding_info) { FactoryBot.build(:collection_branding_banner, file_set_id: nil) }

  describe 'collection_branding_info' do
    context 'with an associated CollectionBrandingInfo' do
      before do
        file_set.save!
        collection_branding_info.update_attributes!(file_set_id: file_set.id)
      end
      it 'returns the object' do
        expect(file_set.collection_branding_info).to eq collection_branding_info
      end
    end
    context 'without an associated CollectionBrandingInfo' do
      it 'returns nil' do
        expect(file_set.collection_branding_info).to be_nil
      end
    end
  end

  describe '#collection_branding?' do
    context 'without an associated branding object' do
      it 'returns false' do
        expect(file_set.collection_branding?).to be false
      end
    end
    context 'with an associated branding object' do
      before do
        allow(file_set).to receive(:collection_branding_info).and_return(collection_branding_info)
      end
      it 'returns true' do
        expect(file_set.collection_branding?).to be true
      end
    end
  end

  let(:external_id) { "s3_id" }
  let(:external_location) { "s3://#{external_id}" }

  describe "#external?" do
    context "when stored in S3" do
      before { allow(file_set).to receive(:content_location).and_return(external_location) }
      it "returns true" do
        expect(file_set.external?).to eq true
      end
    end
    context "when stored in Fedora" do
      it "returns false" do
        expect(file_set.external?).to eq false
      end
    end
  end

  describe "#external_id" do
    context "when stored in S3" do
      before { allow(file_set).to receive(:content_location).and_return(external_location) }
      it "returns the S3 internal id" do
        expect(file_set.external_id).to eq external_id
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
        before { allow(file_set).to receive(:content_location).and_return(external_location) }
        let(:output_filepath) { 'filepath_from_s3' }
        before { allow(ESSI.external_storage).to receive(:find_or_retrieve).and_return(output_filepath) }
        it "calls ESSI.external_storage.find_or_retrieve" do
          expect(ESSI.external_storage).to receive(:find_or_retrieve)
          file_set.find_or_retrieve(filepath: argument_filepath)
        end
        it "returns filepath" do
          expect(file_set.find_or_retrieve(filepath: argument_filepath)).to eq output_filepath
        end
      end
      context "when file is stored in Fedora" do
        let(:output_filepath) { 'filepath_from_fedora' }
        before { allow(Hyrax::WorkingDirectory).to receive(:find_or_retrieve).and_return(output_filepath) }
        it "calls Hyrax::WorkingDirectory.find_or_retrieve" do
          expect(Hyrax::WorkingDirectory).to receive(:find_or_retrieve)
          file_set.find_or_retrieve(filepath: argument_filepath)
        end
        it "returns filepath" do
          expect(file_set.find_or_retrieve(filepath: argument_filepath)).to eq output_filepath
        end
      end
    end
    context "when filepath provided" do
      let(:argument_filepath) { '/tmp/existing_file.txt' }
      context "when file present" do
        before { allow(File).to receive(:exist?).with(argument_filepath).and_return(true) }
        it "returns the filepath" do
          expect(file_set.find_or_retrieve(filepath: argument_filepath)).to eq argument_filepath
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
