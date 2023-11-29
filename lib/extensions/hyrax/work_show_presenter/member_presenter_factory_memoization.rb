module Extensions
  module Hyrax
    module WorkShowPresenter
      module MemberPresenterFactoryMemoization
        # unmodified from hyrax
        def member_presenter_factory
          ::Hyrax::MemberPresenterFactory.new(solr_document, current_ability, request)
        end
      end
    end
  end
end
