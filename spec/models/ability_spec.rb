require 'rails_helper'

RSpec.describe Ability do
  let(:user) { FactoryBot.create :user }
  let(:options) { {} }
  let(:ability) { described_class.new(user, options) }
  let(:authorized_groups) { ['Test group'] }

  describe '#user_groups' do
    context 'when no authorized ldap groups are configured' do
      before(:each) do
        allow(ESSI.config[:authorized_ldap_groups]).to receive(:blank?).and_return(true)
      end
      context 'when a user is persisted' do
        it 'considers the user registered' do
          expect(ability.user_groups).to include('registered')
        end
      end
      context 'when a user is not persisted' do
        let(:user) { FactoryBot.build :user }
        it 'considers the user unregistered' do
          expect(ability.user_groups).not_to include('registered')
        end
      end
    end
    context 'when authorized ldap groups are configured' do
      before(:each) do
        ESSI.config[:authorized_ldap_groups] = authorized_groups
      end
      context 'when the user has authorized group membership' do
        before(:each) do
          allow(user).to receive(:authorized_patron?).and_return(true)
        end
        it 'considers the user registered' do
          expect(ability.user_groups).to include('registered')
        end
      end
      context 'when the user lacks authorized group membership' do
        before(:each) do
          allow(user).to receive(:authorized_patron?).and_return(false)
        end
        it 'considers the user unregistered' do
          expect(ability.user_groups).not_to include('registered')
        end
      end
    end
  end
end
