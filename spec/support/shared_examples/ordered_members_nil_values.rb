RSpec.shared_examples "ordered_members nil values" do |resource_symbol|
  let(:user) { FactoryBot.create(:user) }
  let(:resource) { FactoryBot.create(resource_symbol, depositor: user.email, title: ['Dummy Title']) }
  let(:child1) { FactoryBot.create(:paged_resource, depositor: user.email, title: ['Child 1']) }
  let(:child2) { FactoryBot.create(:paged_resource, depositor: user.email, title: ['Child 2']) }

  describe "#remove_nil_ordered_members" do
    context "without any nil values" do
      let(:ordered_members) { [child1, child2] }
      it "returns nil" do
        expect(resource.remove_nil_ordered_members(ordered_members)).to be_nil
      end
    end
    context "with nil values" do
      let(:ordered_members) { [child1, nil, child2, nil] }
      context "with successful save" do
        before { allow(resource).to receive(:save).and_return(true) }
        it "removes nil values" do
          expect(resource.remove_nil_ordered_members(ordered_members)).to eq [child1, child2]
        end
        it "logs action" do
          expect(Rails.logger).to receive(:error).with("Nil values present in ordered_members of #{resource.class.to_s} #{resource.id} at indexes: 1, 3")
          expect(Rails.logger).to receive(:info).at_least(1).times.with(nil)
          expect(Rails.logger).to receive(:info).with("Nil values successfully removed from ordered_members of #{resource.class.to_s} #{resource.id} at indexes: 1, 3")
          resource.remove_nil_ordered_members(ordered_members)
        end
        it "notifies depositor" do
          expect(resource).to receive(:notify_user_of_nil_values).with(true, [1,3])
          resource.remove_nil_ordered_members(ordered_members)
        end
        it "returns revised ordered_member values" do
          expect(resource.remove_nil_ordered_members(ordered_members)).to eq [child1, child2]
        end
      end
      context "with failed save" do
        before { allow(resource).to receive(:save).and_return(false) }
        before { allow(resource.errors).to receive(:full_messages).and_return(['error1', 'error2']) }
        it "removes nil values" do
          expect(resource.remove_nil_ordered_members(ordered_members)).not_to eq [child1, child2]
        end
        it "logs action" do
          expect(Rails.logger).to receive(:error).with("Nil values present in ordered_members of #{resource.class.to_s} #{resource.id} at indexes: 1, 3")
          expect(Rails.logger).to receive(:info).at_least(1).times.with(nil)
          expect(Rails.logger).to receive(:error).with("Save failure updating resource to remove nil values from ordered_members of #{resource.class.to_s} #{resource.id} at indexes: 1, 3")
          expect(Rails.logger).to receive(:error).with("error1\nerror2")
          resource.remove_nil_ordered_members(ordered_members)
        end
        it "notifies depositor" do
          expect(resource).to receive(:notify_user_of_nil_values).with(false, [1,3])
          resource.remove_nil_ordered_members(ordered_members)
        end
        it "returns false" do
          expect(resource.remove_nil_ordered_members(ordered_members)).to eq false
        end
      end
      context "when an error occurs" do
        before { allow(resource).to receive(:save).and_raise StandardError, "forced save error" }
        it "logs error" do
          expect(Rails.logger).to receive(:error).with("Nil values present in ordered_members of #{resource.class.to_s} #{resource.id} at indexes: 1, 3")
          expect(Rails.logger).to receive(:info).at_least(1).times.with(nil)
          expect(Rails.logger).to receive(:error).with("Error attempting to remove nil values from ordered_members of #{resource.class.to_s} #{resource.id} at indexes: 1, 3")
          expect(Rails.logger).to receive(:error).with("#<StandardError: forced save error>")
          resource.remove_nil_ordered_members(ordered_members)
        end
        it "notifies depositor" do
          expect(resource).to receive(:notify_user_of_nil_values).with(false, [1,3])
          resource.remove_nil_ordered_members(ordered_members)
        end
        it "returns false" do
          expect(resource.remove_nil_ordered_members(ordered_members)).to eq false
        end
      end
    end
  end

  shared_examples "#notify_user_of_nil_values examples" do |success_string, success_value|
    before { allow_any_instance_of(ActionMailer::Base).to receive(:mail).and_return(Mail::Message.new) }
    before { allow_any_instance_of(Mail::Message).to receive(:deliver) }
    context "with #{success_string}" do
      let(:result) { success_value }
      let(:nil_indexes) { [1, 3] }
      context "without depositor email" do
        before { allow(resource).to receive(:depositor).and_return(nil) }
        it "returns nil" do
          expect(resource.notify_user_of_nil_values(result, nil_indexes)).to be_nil
        end
      end
      context "with a depositor email" do
        before { allow(resource).to receive(:depositor).and_return(user.email) }
        it "emails depositor" do
          expect(resource.depositor).not_to be_nil
          expect_any_instance_of(Mail::Message).to receive(:deliver)
          resource.notify_user_of_nil_values(result, nil_indexes)
        end
        context "with matching User record" do
          it "notifies user hyrax dashboard" do
            expect(Hyrax::MessengerService).to receive(:deliver)
            resource.notify_user_of_nil_values(result, nil_indexes)
          end
        end
        context "without a matching User record" do
          before { allow(User).to receive(:find_by_email).and_return(nil) }
          it "does not notify hyrax dashboard"  do
            expect(Hyrax::MessengerService).not_to receive(:deliver)
            resource.notify_user_of_nil_values(result, nil_indexes)
          end
        end
      end
    end
  end

  describe "#notify_user_of_nil_values" do
    include_examples "#notify_user_of_nil_values examples", "success", true
    include_examples "#notify_user_of_nil_values examples", "failure", false
  end
end
