# Generated via
#  `rails generate hyrax:work BibRecord`
require 'rails_helper'
include Warden::Test::Helpers
include ActiveJob::TestHelper

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a BibRecord', type: :system, js: true do
  include_examples "create work feature spec", "BibRecord"
end
