module ExtraLockable
  extend ActiveSupport::Concern
  include Hyrax::Lockable

  included do
    class_attribute :lock_id_attribute
    self.lock_id_attribute = :id

    delegate :lock_manager, to: :LockManagerService
    delegate :lock_checker, to: :LockManagerService

    def check_lock_for(lock_key, &block)
      lock_checker.lock(lock_key, &block)
    end

    def lock_id
      ident = try(lock_id_attribute)
      raise ArgumentError, "lock id attribute cannot be blank" if ident.blank?
      "lock_#{ident}"
    end

    # Provides a way to pass options to the underlying Redlock client.
    def lock(key = lock_id, options = {})
      ttl = options.delete(:ttl) || Hyrax.config.lock_time_to_live
      if block_given?
        lock_manager.client.lock(key, ttl, options, &Proc.new)
      else
        lock_manager.client.lock(key, ttl, options)
      end
    end

    def lock?(key = lock_id)
      check_lock_for(key) { nil }
      Rails.logger.info "ExtraLockable: No lock found for key: #{key}"
      return false
    rescue Hyrax::LockManager::UnableToAcquireLockError
      Rails.logger.info "ExtraLockable: Found a lock for key: #{key}"
      return true
    end

    def unlock(lock_info)
      lock_manager.client.unlock lock_info
    end
  end
end
