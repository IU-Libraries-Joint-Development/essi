module ESSI
  module PagedResourceBehavior
    extend ActiveSupport::Concern
    # Add behaviors that make this work type unique
    included do
      before_save :set_num_pages
    end

  private

    def set_num_pages
      self.num_pages = self.member_ids.size
    end

  end
end
