require 'rails_helper'

RSpec.describe AuthToken, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe '.fetch_token_for' do
    let(:token) { described_class.fetch_token_for(user.email) }

    it 'is valid' do
      expect(token.valid?).to eq(true)
    end

    it 'is persisted' do
      expect(token.persisted?).to eq(true)
    end

    it 'its resource references the user email' do
      expect(token.resource).to eq(user.email)
    end

    it 'has a secure id' do
      expect(token.id).to match(/^[#{SecureRandom::BASE58_ALPHABET.join}]{24}$/)
    end

    it 'expires in approx .ttl seconds' do
      expect(described_class.ttl).to be > 0
      expect(token.expires_in).to be_within(10).of(described_class.ttl)
      expect(token.expires_at).to be_within(10.seconds).of(Time.now + described_class.ttl)
    end

    context 'without randomness' do
      before do
        allow(described_class).to receive(:cleanup_chance) { 1 }
      end

      it 'cleans expired tokens' do
        expect(described_class).to receive(:cleanup_expired_tokens).and_call_original
        expect(described_class).to receive(:expired).and_call_original
        token
      end
    end
  end

  describe '.cleanup_expired_tokens' do
    let(:token) { described_class.create(resource: '1234') }
    before do
      described_class.delete_all
      token.updated_at = 1.month.ago
      token.save
    end

    it 'deletes expired tokens' do
      expect(described_class.count).to eq 1
      expect(described_class.cleanup_expired_tokens(chance: 1)).to eq 1
      expect(described_class.count).to eq 0
    end
  end
end
