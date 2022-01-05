# Generated via
#  `rails generate hyrax:work BibRecord`
require 'rails_helper'

RSpec.describe BibRecord do

  include_examples "MARC Relators"
  include_examples "BibRecord Properties"
  include_examples "round trip update behaviors" do
    let(:new_work) { FactoryBot.build(:bib_record) }
    let(:work) { FactoryBot.create(:bib_record) }
  end
end
