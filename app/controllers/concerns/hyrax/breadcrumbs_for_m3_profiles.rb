module Hyrax
  module BreadcrumbsForM3Profiles
    extend ActiveSupport::Concern
    include Hyrax::Breadcrumbs

    class_methods do
      # We don't want the breadcrumb action to occur until after the concern has
      # been loaded and authorized
      def curation_concern_type=(curation_concern_type)
        super
        before_action :build_breadcrumbs, only: [:edit, :show, :new, :structure, :file_manager]
      end
    end

    private

      def build_breadcrumbs
        return super if action_name == 'show'
        # These breadcrumbs are for the edit/create actions
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb_for_controller
        add_breadcrumb_for_action
      end

      def add_breadcrumb_for_controller
        add_breadcrumb I18n.t(:'hyrax.dashboard.my.works'), hyrax.my_m3_profiles_path
      end

      def add_breadcrumb_for_action
        case action_name
        when 'edit'.freeze
          add_breadcrumb t(:'hyrax.works.edit.breadcrumb'), request.path
        when 'new'.freeze
          add_breadcrumb t(:'hyrax.works.create.breadcrumb'), request.path
        when 'show'.freeze
          add_breadcrumb presenter.to_s, main_app.polymorphic_path(presenter)
        end
      end
  end
end