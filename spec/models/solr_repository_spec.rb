require 'rails_helper'

RSpec.describe ResourceIdentifier::SolrRepository do
  let(:paged_resource) { FactoryBot.create :paged_resource }

  describe ".find" do
    describe "with a matching id" do
      it "returns a Record with a SolrHit record" do
        result = described_class.find(paged_resource.id)
        expect(result).to be_a described_class::Record
        expect(result.record).to be_a ActiveFedora::SolrHit
      end
    end
    describe "with a blank id" do
      it "raises an error" do
        expect { described_class.find('') }.to raise_error RSolr::Error::Http
      end
    end
    describe "with a non-matching id" do
      it "raises an Record with a nil record" do
        result = described_class.find('nonmatchingid')
        expect(result).to be_a described_class::Record
        expect(result.record).to be_nil
      end
    end
  end
end
