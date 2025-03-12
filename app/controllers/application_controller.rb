# NameError: uninitialized constant Hyrax::SearchState
require 'hyrax/search_state'

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  skip_after_action :discard_flash_if_xhr
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  include Essi::PublicAccessBehavior
  with_themed_layout '1_column'
  protect_from_forgery with: :exception

  around_action :global_request_logging

  before_action do
    if defined?(Rack::MiniProfiler) && current_user && current_user.admin?
      Rack::MiniProfiler.authorize_request
    end
  end

  before_action :set_locale

  rescue_from ActionController::UnknownFormat, with: :rescue_404

  def global_request_logging
    logger.info "ACCESS: #{request.remote_ip}, #{request.method} #{request.url}, #{request.headers['HTTP_USER_AGENT']}"
    begin
      yield
    ensure
      logger.info "response_status: #{response.status}"
    end
  end

  def rescue_404
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  def set_locale
    I18n.locale = constrained_locale || I18n.default_locale
  end

  def constrained_locale
    return params[:locale] if params[:locale].in? Object.new.extend(HyraxHelper).available_translations
  end
end
