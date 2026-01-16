require 'rails_helper'

RSpec.describe IuMetadata::METSRecord do
  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:record1) {
    pth = File.join(fixture_path, 'iu_metadata/pudl0001-4609321-s42.mets')
    described_class.new('file://' + pth, open(pth))
  }
  let(:thumbnail_path) { "file:///users/escowles/downloads/tmp/00000001.tif" }

  local_metadata =
    {
      "identifier" => 'ark:/88435/7d278t10z',
      "purl" => 'ark:/88435/7d278t10z',
      "related_url" => [],
      "series" => [],
      "source_metadata_identifier" => 'BHR9405',
      "title" => ['BHR9405'],
      "viewing_direction" => 'left-to-right',
    }
  descriptive_metadata =
    {
      creator: [],
      date_created: [],
      description: [],
      genre: [],
      language: [],
      publisher: [],
      source_identifier: ['BHR9405'],
      source: ['BHR9405'],
      subject: [],
      related_url: [],
      title: [],
    }
  let(:combined_attributes) { local_metadata.dup.merge(descriptive_metadata).with_indifferent_access }

  describe "#attributes" do
    it "provides attibutes" do
      expect(record1.attributes).to eq combined_attributes
    end
  end

  describe "#local_metadata" do
    it "provides attibutes" do
      expect(record1.local_metadata).to eq local_metadata
    end
  end

  describe "#descriptive_metadata" do
    it "provides attibutes" do
      expect(record1.descriptive_metadata).to eq descriptive_metadata
    end
  end

  describe "parses attributes" do
    local_metadata.each do |att, val|
      describe "##{att}" do
        it "retrieves the correct value" do
          expect(record1.send(att)).to eq val
        end
      end
    end
    # exclude overridden title, related_url
    descriptive_metadata.reject { |k,v| k.to_s.in? ['title', 'related_url'] }.each do |att, val|
      describe "##{att}" do
        it "retrieves the correct value" do
          expect(record1.send(att)).to eq val
        end
      end
    end
  end

  describe "#final_url" do
    let(:thumbnail_xpath) { "/mets:mets/mets:fileSec/mets:fileGrp[@USE='thumbnail']/mets:file" }
    let(:file) { record1.instance_variable_get(:@mets).xpath(thumbnail_xpath).first }
    context "when a final redirect url is applicable" do
      let(:final_url) { 'http//final.url' }
      before { allow(IuMetadata::FinalRedirectUrl).to receive(:final_redirect_url).and_return(final_url) }
      it "returns the final redirect url" do
        expect(record1.send(:final_url, file)).to eq final_url
      end
    end
    context "when no final redirect url is applicable" do
      before { allow(IuMetadata::FinalRedirectUrl).to receive(:final_redirect_url).and_return(nil) }
      it "returns the final redirect url, inclusive of any initial file://" do
        expect(record1.send(:final_url, file)).to eq thumbnail_path
      end
    end
  end

  describe "#thumbnail_path" do
    it "returns the xlink:href value, retaining any 'file://' at the beginning" do
      expect(record1.thumbnail_path).to eq thumbnail_path
    end
  end
end
