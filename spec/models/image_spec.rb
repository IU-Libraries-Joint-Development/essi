# Generated via
#  `rails generate hyrax:work Image`
require 'rails_helper'

RSpec.describe Image do

  include_examples "MARC Relators"
  include_examples "Image Properties"
  include_examples "round trip update behaviors" do
    let(:new_work) { FactoryBot.build(:image) }
    let(:work) { FactoryBot.create(:image) }
  end
end
