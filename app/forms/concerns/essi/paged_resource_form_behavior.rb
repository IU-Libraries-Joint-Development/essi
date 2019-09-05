module ESSI
  module PagedResourceFormBehavior
    extend ActiveSupport::Concern
    # Add behaviors that make this work type unique

    included do
      self.terms += [:holding_location, :publication_place, :viewing_direction, :viewing_hint, :ocr_state]
    end
  end
end
