module ESSI
  def self.external_storage
    @external_storage_service ||= ESSI::ExternalStorageService.new
  end
end