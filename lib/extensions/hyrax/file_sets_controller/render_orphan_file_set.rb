# unmodified from hyrax 2.9.6
module Extensions
  module Hyrax
    module FileSetsController
      module RenderOrphanFileSet

        # unmodified from hyrax
        def add_breadcrumb_for_action
          case action_name
          when 'edit'.freeze
            add_breadcrumb I18n.t("hyrax.file_set.browse_view"), main_app.hyrax_file_set_path(params["id"])
          when 'show'.freeze
            add_breadcrumb presenter.parent.to_s, main_app.polymorphic_path(presenter.parent)
            add_breadcrumb presenter.to_s, main_app.polymorphic_path(presenter)
          end
        end
      end
    end
  end
end
