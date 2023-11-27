require 'rails_helper'

RSpec.feature 'Switch User' do
  let(:user) { FactoryBot.create(:user) }

  context 'Non-admin user', :clean do
    before do
      login_as user
    end
    scenario 'is not allowed to see switch user form' do
      visit '/users/sessions/log_in_as'
      expect(page).to have_no_selector('select#switch_user_identifier')
      logout
    end
  end

  context 'Admin user', :clean do
    before do
      login_as user
      allow(user).to receive(:admin?).and_return(true)
    end
    scenario 'is allowed to see switch user form' do
      visit '/users/sessions/log_in_as'
      expect(page).to have_css('select#switch_user_identifier')
      logout
    end
  end
end
