# a modified cherry-pick of Hyrax 3.x
# @todo remove after upgrade to Hyrax 3.x
require 'iiif_manifest'

module Hyrax
  # This gets mixed into FileSetPresenter in order to create
  # a canvas on a IIIF manifest
  module DisplaysImage
    extend ActiveSupport::Concern

    # Creates a display image only where FileSet is an image.
    #
    # @return [IIIFManifest::V3::DisplayContent] the display image required by the manifest builder.
    def display_image
      return nil unless solr_document.image? && current_ability.can?(:read, id)
      return nil unless iiif_path_service.lookup_id

      # @see https://github.com/samvera-labs/iiif_manifest
      IIIFManifest::V3::DisplayContent.new(iiif_path_service.iiif_image_url,
                                           type: 'Image',
                                           width: width,
                                           height: height,
                                           format: 'image/jpeg',
                                           auth_service: auth_service,
                                           iiif_endpoint: iiif_endpoint)
    end

    private

    def iiif_path_service
      @iiif_path_service ||= IIIFFileSetPathService.new(solr_document)
    end

    def iiif_endpoint
      return unless Hyrax.config.iiif_image_server?
      IIIFManifest::IIIFEndpoint.new(
        iiif_path_service.iiif_info_url(request.base_url),
        profile: Hyrax.config.iiif_image_compliance_level_uri
      )
    end

    def auth_service
      return {} if content_location.blank?
      {
        "@context": "http://iiif.io/api/auth/1/context.json",
        "@id": Rails.application.routes.url_helpers.new_user_session_url(host: request.base_url, iiif_auth_login: true),
        "@type": "AuthCookieService1",
        "confirmLabel": I18n.t('iiif_av.auth.confirmLabel'),
        "description": I18n.t('iiif_av.auth.description'),
        "failureDescription": I18n.t('iiif_av.auth.failureDescription'),
        "failureHeader": I18n.t('iiif_av.auth.failureHeader'),
        "header": I18n.t('iiif_av.auth.header'),
        "label": I18n.t('iiif_av.auth.label'),
        "profile": "http://iiif.io/api/auth/1/login",
        "service": [
          {
            "@id": Rails.application.routes.url_helpers.auth_token_url(id: Base64.urlsafe_encode64(content_location), host: request.base_url),
            "@type": "AuthTokenService1",
            "profile": "http://iiif.io/api/auth/1/token"
          },
          {
            "@id": Rails.application.routes.url_helpers.destroy_user_session_url(host: request.base_url),
            "@type": "AuthLogoutService1",
            "label": I18n.t('iiif_av.auth.logoutLabel'),
            "profile": "http://iiif.io/api/auth/1/logout"
          }
        ]
      }
    end
  end
end
