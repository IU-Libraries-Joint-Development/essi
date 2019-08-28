##
# Returns a unique resource identifier for the current state of a given scanned
#   resource ID in Fedora.
class ResourceIdentifier
  attr_reader :id, :repository
  def initialize(id, repository = nil)
    @id = id
    @repository = repository || SolrRepository
  end

  # Unique key of the object pointed to by ID's state.
  def digest
    @digest ||= Digest::MD5.hexdigest(@id + timestamp)
  end
  alias_method :to_s, :digest

  # Reload's this resource identifier so it's recalculated by #to_s.
  def reload
    @digest = nil
    @timestamp = nil
    self
  end

  # Combined timestamp of this resource and all its state dependancies.
  def timestamp
    @timestamp ||= solr_record.timestamp
  end

  private

    def solr_record
      repository.find(id)
    end
end
