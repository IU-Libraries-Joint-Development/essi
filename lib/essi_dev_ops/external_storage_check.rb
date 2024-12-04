module EssiDevOps
  # Checks health of external storage service
  include OkComputer
  class ExternalStorageCheck < Check
    def check
      if ESSI::ExternalStorageService.health
        mark_message "External storage is up"
      else
        raise "External storage check failed"
      end
    rescue => e # rubocop:disable Lint/RescueWithoutErrorClass
      mark_failure
      mark_message e
    end
  end
end
