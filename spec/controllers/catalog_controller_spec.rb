require 'rails_helper'

describe CatalogController do
  describe 'saved searches' do
    it 'does not save searches' do
      expect { get 'index', params: { q: 'test' } }.not_to change { Search.count }
    end
  end
end
