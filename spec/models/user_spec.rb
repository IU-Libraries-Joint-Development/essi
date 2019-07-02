require 'rails_helper'

RSpec.describe User, type: :model do
  let(:included_modules) { described_class.included_modules }
  let(:user) { described_class.new }

  it 'has IuUserRoles functionality' do
    expect(included_modules).to include(::IuUserRoles)
    expect(included_modules).to include(LDAPGroupsLookup::Behavior)
    expect(user).to respond_to(:campus_patron?)
    expect(user).to respond_to(:image_editor?)
    expect(user).to respond_to(:ldap_lookup_key)
  end
  it 'has Hydra Role Management behaviors' do
    expect(included_modules).to include(Hydra::RoleManagement::UserRoles)
    expect(user).to respond_to(:admin?)
  end

  describe "#campus_patron?" do
    context "when logged in from CAS" do
      let(:user) do
        described_class.find_for_iu_cas(OpenStruct.new(provider: "cas",
                                                     uid: "testuser"))
      end

      it "is true" do
        expect(user).to be_campus_patron
      end
    end
    context "when not logged in from CAS" do
      before(:each) do
        allow(user).to receive(:provider).and_return(:not_cas)
      end
      it "is false" do
        expect(user).not_to be_campus_patron
      end
    end
  end

  describe "#music_patron?" do
    context "when not a campus_patron" do
      before(:each) do
        allow(user).to receive(:campus_patron?).and_return(false)
      end
      it "is false" do
        expect(user).not_to be_campus_patron
      end
    end
    context "when a campus patron" do
      before(:each) do
        allow(user).to receive(:campus_patron?).and_return(true)
      end
      context "without authorized groups configured" do
        before(:each) do
          allow(ESSI.config[:authorized_ldap_groups]).to receive(:blank?).and_return(true)
        end
        it "is true" do
          expect(user).to be_music_patron
        end
      end
      context "with authorized ldap groups configured" do
        context "when the user has group membership" do
          before(:each) { allow(user).to receive(:authorized_ldap_member?).and_return(true) }
          it "is true" do
            expect(user).to be_music_patron
          end
        end
        context "when the user lacks group membership" do
          before(:each) { allow(user).to receive(:authorized_ldap_member?).and_return(false) }
          it "is false" do
            expect(user).not_to be_music_patron
          end
        end
      end
    end
  end
end
