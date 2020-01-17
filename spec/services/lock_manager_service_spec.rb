require 'rails_helper'

RSpec.describe LockManagerService do
  describe '.lock_manager' do
    it 'returns a LockManager instance' do
      expect(described_class.lock_manager).to be_a Hyrax::LockManager
    end
  end
  describe '.lock_checker' do
    it 'returns a LockManager instance' do
      expect(described_class.lock_checker).to be_a Hyrax::LockManager
    end
  end
end
