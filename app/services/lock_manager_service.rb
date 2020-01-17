class LockManagerService
  def self.lock_manager
    @@lock_manager ||= ::Hyrax::LockManager.new(
      Hyrax.config.lock_time_to_live,
      Hyrax.config.lock_retry_count,
      Hyrax.config.lock_retry_delay
    )
  end

  # Returns a LockManager with minimal settings sufficient for testing locks
  def self.lock_checker
    @@lock_checker ||= ::Hyrax::LockManager.new(10, 0, 0)
  end
end
