class AuthController < ApplicationController
  before_action :load_resource

  # params[:id] resource identifier (as known by IIIF image server)
  # params[:messageId]
  # params[:origin]
  def token
    readable = can?(:read, @resource)
    return head :unauthorized unless readable
    return head :ok if readable && current_user&.email.blank? # Anonymous public access
    response.set_header('Content-Security-Policy', 'frame-ancestors *')
    auth_token = AuthToken.fetch_token_for(current_user.email)
    render html: auth_token_html_response(auth_token)
  end

  def probe
    return head :ok if @resource.public?
    return head :ok if valid_token? && @auth_token.user.ability.can?(:read, @resource)
    request_http_token_authentication
  end

  private

  def load_resource
    @identifier = Base64.urlsafe_decode64(params[:id])
    @resource = SolrDocument.new(find_by_content_location(@identifier))
    @auth_token = load_token
  end

  def find_by_content_location(loc)
    FileSet.search_with_conditions(content_location_tesim: loc).first
  end

  # @token opaque string
  def auth_token_html_response(token)
    message = { messageId: params[:messageId], accessToken: token.id, expiresIn: token.expires_in }
    origin = Rails::Html::FullSanitizer.new.sanitize(params[:origin])
    "<html><body><script>window.parent.postMessage(#{message.to_json}, \"#{origin}\");</script></body></html>".html_safe
  end

  def valid_token?
    @auth_token.present?
  end

  def token_string
    request.headers['Authorization']&.sub('Bearer ', '')&.strip
  end

  def load_token
    AuthToken.valid.find_by(id: token_string)
  end
end
