# Generated via
#  `rails generate hyrax:work Scientific`
require 'rails_helper'

RSpec.describe Scientific do

  include_examples"Scientific Properties"
  include_examples "round trip update behaviors" do
    let(:new_work) { FactoryBot.build(:scientific) }
    let(:work) { FactoryBot.create(:scientific) }
  end

end
