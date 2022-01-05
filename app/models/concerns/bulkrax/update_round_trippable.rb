# requires a multi-valued "source_identifier" field, conigured in bulkrax intializer
module Bulkrax
  module UpdateRoundTrippable
    extend ActiveSupport::Concern
    included do
      before_update :update_round_trippable
    end
    def update_round_trippable
      values = self.source_identifier.to_a
      unless values.include? self.id
        values << self.id
        self.source_identifier = values
      end
    end
  end
end
