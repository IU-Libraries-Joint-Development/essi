RSpec.shared_examples "round trip update behaviors" do
  describe "#save" do
    context "of a new work" do
      it "assigns id to source_identifier" do
        new_work.source_identifier = []
        new_work.save
        expect(new_work.source_identifier).to include(new_work.id)
      end
    end
    context "of an existing work" do
      it "assigns id to source_identifier" do
        work.source_identifier = []
        work.save
        expect(work.source_identifier).to include(work.id)
      end
    end
  end
end
