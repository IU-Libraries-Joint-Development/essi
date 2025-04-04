Rack::Attack.enabled = ESSI.config.dig(:rack_attack, :enabled) || false

Rack::Attack.throttled_response_retry_after_header = true

Rack::Attack.safelist('Safe') do |req|
  EssiDevOps::RackAttackConfig.safe_req?(req)
end

Rack::Attack.blocklist('Blocked') do |req|
  EssiDevOps::RackAttackConfig.block_req?(req)
end

Rack::Attack.throttle('Throttled',
                      limit: ESSI.config.dig(:rack_attack, :throttle_limit) || 100,
                      period: ESSI.config.dig(:rack_attack, :throttle_period) || 2.minutes) do |req|
  EssiDevOps::RackAttackConfig.throttle_req?(req)
end
