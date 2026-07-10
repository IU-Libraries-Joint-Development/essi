# Generated via
#  `rails generate hyrax:work PagedResource`
require 'rails_helper'
include Warden::Test::Helpers
include ActiveJob::TestHelper

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a PagedResource', type: :system, js: true do
  include_examples "create work feature spec", "PagedResource"
end
