# requires a multi-valued "source_identifier" field, conigured in bulkrax intializer
module Bulkrax
  module UpdateCollectionRoundTrippable
    extend ActiveSupport::Concern
    included do
      before_save :update_collection_round_trippable
    end
    def update_collection_round_trippable
      values = self.source_identifier.to_a
      unless values.include? self.title.first
        values << self.title.first
        self.source_identifier = values
      end
    end
  end
end
