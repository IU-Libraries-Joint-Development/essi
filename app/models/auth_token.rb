class AuthToken < ApplicationRecord
  has_secure_token :id
  validates_presence_of :resource
  after_create { AuthToken.cleanup_expired_tokens }
  scope :valid, -> { where('auth_tokens.updated_at > ?', Time.now - ttl) }
  scope :expired, -> { where('auth_tokens.updated_at <= ?', Time.now - ttl) }

  # Returns an unexpired AuthToken for the given user email
  def self.fetch_token_for(email)
    token = valid.find_or_initialize_by(resource: email)
    token.persisted? ? token.touch : token.save
    token
  end

  def self.cleanup_expired_tokens(chance: AuthToken.cleanup_chance)
    if rand(chance) == 0
      count = AuthToken.expired.delete_all
      Rails.logger.info { "Cleaned up #{count} expired AuthTokens" }
      count
    end
  end

  def self.cleanup_chance
    ESSI.config.dig(:iiif_auth, :cleanup_chance) || 1000
  end

  def self.ttl
    (ESSI.config.dig(:iiif_auth, :ttl) || 60).minutes
  end

  def expires_in
    (updated_at + AuthToken.ttl - Time.now).to_i
  end

  def expires_at
    updated_at + AuthToken.ttl
  end
end
