BrowseEverythingController.before_action do
  # Skip this new functionality if dropbox config file doesn't exist or is invalid yaml
  if (params[:context].present? && browser.providers[:file_system].present? && !current_user&.admin? && dropbox_map.present?)
    new_base_path = dropbox_map[params[:context]] if dropbox_map.key?(params[:context])

    # Scope Browse-Everything to configured home for this request
    browser.providers[:file_system].config[:home] = new_base_path if new_base_path.present?
  end
end

BrowseEverythingController.prepend_before_action do
  raise CanCan::AccessDenied unless current_ability&.can_import_works?
end

BrowseEverythingController.class_eval do
  # Include handling of CanCan::AccessDenied
  include Hydra::Controller::ControllerBehavior

  # Override to add memoization included in future versions of browse-everything
  def browser
    @browser ||= BrowserFactory.build(session: session, url_options: url_options)
  end

  private

  def dropbox_map
    @dropbox_map ||= YAML.load_file(Rails.root.join('config', 'browse_everything_dropboxes.yml')) rescue nil
  end
end
