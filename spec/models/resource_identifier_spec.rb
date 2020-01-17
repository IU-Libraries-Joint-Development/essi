require 'rails_helper'

RSpec.describe ResourceIdentifier do
  let(:paged_resource) { FactoryBot.create :paged_resource }
  let(:resource_identifier) { described_class.new(paged_resource.id) }
  let(:solr_record) { resource_identifier.send(:solr_record) }

  describe "#digest" do
    it "changes when the timestamp changes" do
      digest = resource_identifier.digest
      paged_resource.save
      resource_identifier.reload
      expect(resource_identifier.digest).not_to eq digest
    end
  end

  describe "#reload" do
    [:digest, :timestamp].each do |attribute|
      it "nullifies the #{attribute}" do
        expect(resource_identifier.send(attribute)).not_to be_nil
        resource_identifier.reload
        expect(resource_identifier.instance_variable_get("@#{attribute}")).to be_nil
      end
    end
  end

  describe "#timestamp" do
    it "returns the resource's solr timestamp" do
      expect(resource_identifier.timestamp).to eq solr_record.timestamp
    end
  end
end
