# frozen_string_literal: true

module ESSI
  module OptimizedAdminSetLookup
    extend ActiveSupport::Concern

    def admin_set_id
      # Replaces following from AllinsonFlex::DynamicPresenterBehavior
      # @admin_set_id ||= AdminSet.where(title: self.admin_set).first&.id

      @admin_set_id ||= ActiveFedora::SolrService.query(
        "has_model_ssim:AdminSet AND title_sim:\"#{admin_set.first}\"", fl: 'id', rows: 1).first&.[]('id')
    end
  end
end