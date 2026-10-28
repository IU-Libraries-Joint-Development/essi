# Special session management for CAS
#
# Copyright:: Copyright 2016 Indiana University

# This class eventually descends from ApplicationController
class Users::SessionsController < Devise::SessionsController

  def destroy
    super do
      unset_iiif_auth_cookie
    end
  end

  # Quiet, RuboCop!

  # GET /resource/global_sign_out
  # Destroy the local session and then request CAS to invalidate the TGT.
  def global_logout
    # Copied from devise/sessions_controller.rb
    if Devise.sign_out_all_scopes
    then sign_out
    else sign_out(resource_name)
    end

    # Now sign out of CAS
    options = Devise.omniauth_configs[:cas].options
    host = options[:host] || 'localhost'
    path = options[:logout_url] || '/logout'
    redirect_to "https://#{host}#{path}"
  end

  def log_in_as; end

  def sign_in_autoclose
    set_iiif_auth_cookie
    render inline: "<html><head><script>window.close();</script></head><body></body></html>".html_safe
  end
end
