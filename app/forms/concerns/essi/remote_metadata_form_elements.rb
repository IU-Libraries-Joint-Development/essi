module ESSI
  module RemoteMetadataFormElements
    extend ActiveSupport::Concern

    included do
      self.terms += [:source_metadata_identifier]
      self.primary_fields += [:source_metadata_identifier]
    end
  end
end
