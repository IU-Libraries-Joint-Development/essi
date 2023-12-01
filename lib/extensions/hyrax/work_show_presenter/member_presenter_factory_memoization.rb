module Extensions
  module Hyrax
    module WorkShowPresenter
      module MemberPresenterFactoryMemoization
        # modified from hyrax to add memoization
        def member_presenter_factory
          @member_presenter_factory ||= ::Hyrax::MemberPresenterFactory.new(solr_document, current_ability, request)
        end
      end
    end
  end
end
