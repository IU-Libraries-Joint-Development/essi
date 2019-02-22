module Hyrax
  module Workflow
    class FlaggedForReviewNotification < AbstractNotification
      private

      def subject
        'Deposit flagged for review'
      end

      def message
        "#{title} (#{link_to work_id, document_path}) flagged for review by  #{user.user_key}.\n\n '#{comment}'"
      end

      def users_to_notify
        user_key = document.depositor
        super << ::User.find_by(email: user_key)
      end
    end
  end
end