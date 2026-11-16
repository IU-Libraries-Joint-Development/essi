class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cas
    @user = User.find_for_iu_cas(request.env["omniauth.auth"])
    if @user.persisted?
      @user.authorized_ldap_member?(:force) if
          ESSI.config[:authorized_ldap_groups].present?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated  
      set_flash_message(:notice, :success, :kind => "IU CAS") if is_navigational_format?
    else
      session["devise.cas_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  private

  def after_sign_in_path_for(resource_or_scope)
    return Rails.application.routes.url_helpers.sign_in_autoclose_path if referer_iiif_login? || request_iiif_login?
    super
  end

  def referer_iiif_login?
    # When going through the login form
    referer_uri_string = request.env.fetch("HTTP_REFERER", nil)
    return false unless referer_uri_string.present?
    referer_uri = URI(referer_uri_string)
    # Don't worry about referers that come from a different site (includings where the IIIF viewer is embedded)
    return false if referer_uri.host.present? && referer_uri.host != request.host
    query_params = Rack::Utils.parse_query(referer_uri.query)
    query_params && ActiveModel::Type::Boolean.new.cast(query_params["iiif_auth_login"])
  end

  def request_iiif_login?
    # When already logged in
    request_uri_string = request.env.fetch("REQUEST_URI", nil)
    return false unless request_uri_string.present?
    request_uri = URI(request_uri_string)
    query_params = Rack::Utils.parse_query(request_uri.query)
    ActiveModel::Type::Boolean.new.cast(query_params["iiif_auth_login"])
  end
end
