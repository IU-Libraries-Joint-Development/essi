require 'rails_helper'

RSpec.describe IIIFFileSetPathService do
  let(:base_url) { 'http://localhost:3000/' }
  let(:content_location) { 's3://localhost:9000/essi-test/ext-store/12/34/ab/cd/1234abcd-original_file.ptif' }
  let(:local_file) { File.open(RSpec.configuration.fixture_path + '/world.png') }
  # must explicitly define :file_set, normally as one of three following options
  let(:empty_file_set) { FactoryBot.create(:file_set) }
  let(:local_file_set) { FactoryBot.create(:file_set, content: local_file) }
  let(:remote_file_set) { FactoryBot.create(:file_set, content_location: content_location) }
  let(:solr_hit) { FileSet.search_with_conditions(id: file_set.id).first }
  let(:solr_document) { SolrDocument.new(solr_hit) }
  # must explicitly define :source if using file_set_presenter
  let(:file_set_presenter) { Hyrax::FileSetPresenter.new(source, Ability.new(FactoryBot.build(:user))) }
  let(:versioned_lookup) { false } # default, override when desired
  # must explicitly define :resource
  let(:service) { described_class.new(resource, versioned_lookup: versioned_lookup) }

  # requires defining lookup_id, url
  shared_examples "url examples" do
    context "without a lookup_id value" do
      let(:file_set) { empty_file_set }
      it "returns nil" do
        expect(lookup_id).to be_nil
        expect(url).to be_nil
      end
    end
    context "with an original_file_id lookup_id value" do
      let(:file_set) { local_file_set }
      it "returns a url" do
        expect(lookup_id).not_to match /^s3/
        expect(url).to match /^http/
      end
    end
    context "with a content_location lookup_id value" do
      let(:file_set) { remote_file_set }
      it "returns a url" do
        expect(lookup_id).to match /^s3/
        expect(url).to match /^http/
      end
    end
    context "with versioned_file_id lookup" do
      let(:file_set) { empty_file_set }
      let(:versioned_lookup) { true }
      context "that fails" do
        it "returns nil" do
          expect(lookup_id).to be_nil
          expect(url).to be_nil
        end
      end
      context "that succeeds" do
        before do
          allow(service).to receive(:original_file).and_return(local_file_set.original_file)
        end
        it "returns a url" do
          expect(lookup_id).not_to match /^s3/
          expect(url).to match /^http/
          # below is proxy check that #versioned_file_id was called
          expect(service.instance_variable_get(:@versioned_file_id)).not_to be_nil
        end
      end
    end
  end

  # requires defining resource
  shared_examples "#iiif_(image|info)_url examples" do
    let(:lookup_id) { service.lookup_id }
    describe "#iiif_image_url" do
      let(:url) { service.iiif_image_url }
      include_examples "url examples"
    end
    describe "#iiif_info_url" do
      let(:url) { service.iiif_info_url(base_url) }
      include_examples "url examples"
    end
  end

  context "for an ActiveFedora::SolrHit" do
    let(:resource) { solr_hit }
    include_examples "#iiif_(image|info)_url examples"
  end

  context "for a FileSet" do
    context "directly" do
      let(:resource) { file_set }
      include_examples "#iiif_(image|info)_url examples"
    end
    context "sourcing a Hyrax::FileSetPresenter" do
      let(:source) { file_set }
      let(:resource) { file_set_presenter }
      include_examples "#iiif_(image|info)_url examples"
    end
  end

  context "for a SolrDocument" do
    context "directly" do
      let(:resource) { solr_document }
      include_examples "#iiif_(image|info)_url examples"
    end
    context "sourcing a Hyrax::FileSetPresenter" do
      let(:source) { solr_document }
      let(:resource) { file_set_presenter }
      include_examples "#iiif_(image|info)_url examples"
    end
  end

  context "for a Hash" do
    let(:resource) { solr_document.to_h }
    include_examples "#iiif_(image|info)_url examples"
  end
end
