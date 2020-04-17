module ESSI
  module NumPagesBehavior
    extend ActiveSupport::Concern
    included do
      before_save :set_num_pages
    end

    private

      def set_num_pages
        self.num_pages = self.member_ids.size
      end
  end
end
