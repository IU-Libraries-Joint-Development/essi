require 'java'
require 'cgi'
require 'net/http'
require 'openssl'
require 'base64'

# Delegate script to use Fedora as an HttpSource.

##
# Sample Ruby delegate script containing stubs and documentation for all
# available delegate methods. See the user manual for more information.
#
# The application will create an instance of this class early in the request
# cycle and dispose of it at the end of the request cycle. Instances don't need
# to be thread-safe, but sharing information across instances (requests)
# **does** need to be done thread-safely.
#
# This version of the script works with Cantaloupe version >= 5.
#
class CustomDelegate

  ##
  # Attribute for the request context, which is a hash containing information
  # about the current request.
  #
  # This attribute will be set by the server before any other methods are
  # called. Methods can access its keys like:
  #
  # ```
  # identifier = context['identifier']
  # ```
  #
  # The hash will contain the following keys in response to all requests:
  #
  # * `client_ip`        [String] Client IP address.
  # * `cookies`          [Hash<String,String>] Hash of cookie name-value pairs.
  # * `full_size`        [Hash<String,Integer>] Hash with `width` and `height`
  #                      keys corresponding to the pixel dimensions of the
  #                      source image.
  # * `identifier`       [String] Image identifier.
  # * `local_uri`        [String] URI seen by the application, which may be
  #                      different from `request_uri` when operating behind a
  #                      reverse-proxy server.
  # * `metadata`         [Hash<String,Object>] Embedded image metadata. Object
  #                      structure varies depending on the source image.
  #                      See the `metadata()` method.
  # * `page_count`       [Integer] Page count.
  # * `page_number`      [Integer] Page number.
  # * `request_headers`  [Hash<String,String>] Hash of header name-value pairs.
  # * `request_uri`      [String] URI requested by the client.
  # * `scale_constraint` [Array<Integer>] Two-element array with scale
  #                      constraint numerator at position 0 and denominator at
  #                      position 1.
  #
  # It will contain the following additional string keys in response to image
  # requests, after the image has been accessed:
  #
  # * `operations`     [Array<Hash<String,Object>>] Array of operations in
  #                    order of application. Only operations that are not
  #                    no-ops will be included. Every hash contains a `class`
  #                    key corresponding to the operation class name, which
  #                    will be one of the `e.i.l.c.operation.Operation`
  #                    implementations.
  # * `output_format`  [String] Output format media (MIME) type.
  # * `resulting_size` [Hash<String,Integer>] Hash with `width` and `height`
  #                    keys corresponding to the pixel dimensions of the
  #                    resulting image after all operations have been applied.
  #
  # @return [Hash] Request context.
  #
  attr_accessor :context

  ##
  # Deserializes the given meta-identifier string into a hash of its component
  # parts.
  #
  # This method is used only when the `meta_identifier.transformer`
  # configuration key is set to `DelegateMetaIdentifierTransformer`.
  #
  # The hash contains the following keys:
  #
  # * `identifier`       [String] Required.
  # * `page_number`      [Integer] Optional.
  # * `scale_constraint` [Array<Integer>] Two-element array with scale
  #                      constraint numerator at position 0 and denominator at
  #                      position 1. Optional.
  #
  # @param meta_identifier [String]
  # @return Hash<String,Object> See above. The return value should be
  #                             compatible with the argument to
  #                             {serialize_meta_identifier}.
  #
  def deserialize_meta_identifier(meta_identifier)
    { 'identifier' => Base64.urlsafe_decode64(meta_identifier) }
  end

  ##
  # Serializes the given meta-identifier hash.
  #
  # This method is used only when the `meta_identifier.transformer`
  # configuration key is set to `DelegateMetaIdentifierTransformer`.
  #
  # See {deserialize_meta_identifier} for a description of the hash structure.
  #
  # @param components [Hash<String,Object>]
  # @return [String] Serialized meta-identifier compatible with the argument to
  #                  {deserialize_meta_identifier}.
  #
  def serialize_meta_identifier(components)
    Base64.urlsafe_encode64(components['identifier'])
  end

  ##
  # Returns authorization status for the current request. This method is called
  # upon all requests to all public endpoints early in the request cycle,
  # before the image has been accessed. This means that some context keys (like
  # `full_size`) will not be available yet.
  #
  # This method should implement all possible authorization logic except that
  # which requires any of the context keys that aren't yet available. This will
  # ensure efficient authorization failures.
  #
  # Implementations should assume that the underlying resource is available,
  # and not try to check for it.
  #
  # Possible return values:
  #
  # 1. Boolean true/false, indicating whether the request is fully authorized
  #    or not. If false, the client will receive a 403 Forbidden response.
  # 2. Hash with a `status_code` key.
  #     a. If it corresponds to an integer from 200-299, the request is
  #        authorized.
  #     b. If it corresponds to an integer from 300-399:
  #         i. If the hash also contains a `location` key corresponding to a
  #            URI string, the request will be redirected to that URI using
  #            that code.
  #         ii. If the hash also contains `scale_numerator` and
  #            `scale_denominator` keys, the request will be
  #            redirected using that code to a virtual reduced-scale version of
  #            the source image.
  #     c. If it corresponds to 401, the hash must include a `challenge` key
  #        corresponding to a WWW-Authenticate header value.
  #
  # @param options [Hash] Empty hash.
  # @return [Boolean,Hash<String,Object>] See above.
  #
  def pre_authorize(options = {})
    logger = Java::edu.illinois.library.cantaloupe.delegate.Logger
    token_endpoint = URI(auth_internal_host + '/auth/token/')
    probe_endpoint = URI(auth_internal_host + '/auth/probe/')
    file_id = CGI.escape(context['identifier'])

    conn = Net::HTTP.new(token_endpoint.host, token_endpoint.port)
    conn.use_ssl = true
    conn.verify_mode = OpenSSL::SSL::VERIFY_NONE if ENV.fetch('CANTALOUPE_AUTH_SSL_VERIFY_NONE', 'false') == 'true'

    auth_param = /auth=(\w{24})/.match(URI(context['local_uri']).query)&.[](1)
    authorization_header = context['request_headers']['Authorization'] ||
                           context['cookies'][auth_cookie_name] ||
                           auth_param || ''
    logger.debug "PreAuth: #{context['identifier']} Auth: #{authorization_header}"

    if authorization_header != ''
      auth_token = authorization_header.split(' ').last
    else
      token_uri = URI("#{token_endpoint}#{file_id}")
      token_req = Net::HTTP::Head.new(token_uri)
      token_resp = conn.start { |http|
        http.request(token_req)
      }
      logger.debug "Token Response: #{token_resp.code} #{token_resp.uri}"
      auth_token = token_resp.fetch('Authorization', '').split(' ').last
    end

    probe_uri = URI("#{probe_endpoint}#{Base64.urlsafe_encode64(context['identifier'])}")
    probe_req = Net::HTTP::Head.new(probe_uri)
    probe_req['Authorization'] = auth_token

    probe_resp = conn.start { |http|
      http.request(probe_req)
    }
    logger.debug "Probe Response: #{probe_resp.code} #{context['identifier']} | #{authorization_header}"
    status_code = probe_resp.code.to_i
    return_hash = { 'status_code' => status_code }
    return_hash['challenge'] = 'Bearer realm="iiif" charset="UTF-8"' if status_code == 401
    return_hash
  end

  def auth_external_host
    ENV.fetch('CANTALOUPE_AUTH_EXTERNAL_HOST') { 'https://localhost:3000' }
  end

  def auth_internal_host
    ENV.fetch('CANTALOUPE_AUTH_INTERNAL_HOST') { 'https://web:3000' }
  end

  def auth_cookie_name
    ENV.fetch('CANTALOUPE_AUTH_COOKIE_NAME') { 'iiif-auth' }
  end

  ##
  # Returns authorization status for the current request. Will be called upon
  # all requests to all public image (not information) endpoints.
  #
  # This is a counterpart of `pre_authorize()` that is invoked later in the
  # request cycle, once more information about the underlying image has become
  # available. It should only contain logic that depends on context keys that
  # contain information about the source image (like `full_size`, `metadata`,
  # etc.)
  #
  # Implementations should assume that the underlying resource is available,
  # and not try to check for it.
  #
  # @param options [Hash] Empty hash.
  # @return [Boolean,Hash<String,Object>] See the documentation of
  #                                       `pre_authorize()`.
  #
  def authorize(options = {})
    true
  end

  ##
  # Adds additional keys to an Image API 2.x information response. See the
  # [IIIF Image API 2.1](http://iiif.io/api/image/2.1/#image-information)
  # specification and "endpoints" section of the user manual.
  #
  # @param options [Hash] Empty hash.
  # @return [Hash] Hash to merge into an Image API 2.x information response.
  #                Return an empty hash to add nothing.
  #
  def extra_iiif2_information_response_keys(options = {})
    {
      "service": {
        "@context": "http://iiif.io/api/auth/1/context.json",
        "@id": "#{auth_external_host}/users/auth/cas?iiif_auth_login=true",
        "@type": "AuthCookieService1",
        "confirmLabel": "Login",
        "description": "You must login to view this content.",
        "failureDescription": "<a href=\"https://digitalcollections.iu.edu/about\">More Information</a>",
        "failureHeader": "Authentication Failed",
        "header": "Please Log In",
        "label": "Login Required",
        "profile": "http://iiif.io/api/auth/1/login",
        "service": [
          {
            "@id": "#{auth_external_host}/auth/token/#{Base64.urlsafe_encode64(context['identifier'])}",
            "@type": "AuthTokenService1",
            "profile": "http://iiif.io/api/auth/1/token"
          },
          {
            "@id": "#{auth_external_host}/sign_out",
            "@type": "AuthLogoutService1",
            "label": "Log out",
            "profile": "http://iiif.io/api/auth/1/logout"
          }
        ]
      }
    }
  end

  ##
  # Adds additional keys to an Image API 3.x information response. See the
  # [IIIF Image API 3.0](http://iiif.io/api/image/3.0/#image-information)
  # specification and "endpoints" section of the user manual.
  #
  # @param options [Hash] Empty hash.
  # @return [Hash] Hash to merge into an Image API 3.x information response.
  #                Return an empty hash to add nothing.
  #
  def extra_iiif3_information_response_keys(options = {})
    extra_iiif2_information_response_keys(options)
  end

  ##
  # Tells the server which source to use for the given identifier.
  #
  # @param options [Hash] Empty hash.
  # @return [String] Source name.
  #
  def source(options = {})
    case context['identifier'].split(':').first
    when 's3'
      'S3Source'
    else
      'HttpSource'
    end
  end

  ##
  # N.B.: this method should not try to perform authorization. `authorize()`
  # should be used instead.
  #
  # @param options [Hash] Empty hash.
  # @return [String,nil] Blob key of the image corresponding to the given
  #                      identifier, or nil if not found.
  #
  def azurestoragesource_blob_key(options = {})
  end

  ##
  # N.B.: this method should not try to perform authorization. `authorize()`
  # should be used instead.
  #
  # @param options [Hash] Empty hash.
  # @return [String,nil] Absolute pathname of the image corresponding to the
  #                      given identifier, or nil if not found.
  #
  def filesystemsource_pathname(options = {})
  end

  ##
  # Returns one of the following:
  #
  # 1. String URI
  # 2. Hash with the following keys:
  #     * `uri`               [String] (required)
  #     * `username`          [String] For HTTP Basic authentication
  #                           (optional).
  #     * `secret`            [String] For HTTP Basic authentication
  #                           (optional).
  #     * `headers`           [Hash<String,String>] Hash of request headers
  #                           (optional).
  #     * `send_head_request` [Boolean] Optional; defaults to `true`. See the
  #                           documentation of the
  #                           `HttpSource.BasicLookupStrategy.send_head_requests`
  #                           configuration key.
  # 3. nil if not found.
  #
  # N.B.: this method should not try to perform authorization. `authorize()`
  # should be used instead.
  #
  # @param options [Hash] Empty hash.
  # @return See above.
  #
  def httpsource_resource_info(_options = {})
    logger = Java::edu.illinois.library.cantaloupe.delegate.Logger

    fedora_base = ENV.fetch('CANTALOUPE_FEDORA_BASE') { 'http://localhost:8984' }
    fedora_path = ENV.fetch('CANTALOUPE_FEDORA_PATH') { '/rest/dev' }
    fedora_username = ENV.fetch('CANTALOUPE_FEDORA_USERNAME') { 'fedoraAdmin' }
    fedora_password = ENV.fetch('CANTALOUPE_FEDORA_PASSWORD') { 'fedoraAdmin' }

    # Code from https://slides.com/ksclarke/integrating-cantaloupe/fullscreen#/3
    file_id = context['identifier']

    # Split the parts into Fedora's pseudo-pairtree (only first four pairs)
    paths = file_id.split(/(.{0,2})/).reject!(&:empty?)[0, 4]

    url = CGI::unescape(fedora_base + fedora_path + '/' + paths.join('/') + '/' + file_id)
    logger.info "Fedora ID: #{file_id} | Delegated URL: #{url}"
    return { 'uri' => url, 'username' => fedora_username, 'secret' => fedora_password }
  end

  ##
  # N.B.: this method should not try to perform authorization. `authorize()`
  # should be used instead.
  #
  # @param options [Hash] Empty hash.
  # @return [String, nil] Database identifier of the image corresponding to the
  #                       identifier in the context, or nil if not found.
  #
  def jdbcsource_database_identifier(options = {})
  end

  ##
  # Returns either the last-modified timestamp of an image in ISO 8601 format,
  # or an SQL statement that can be used to retrieve it from a `TIMESTAMP`-type
  # column in the database. In the latter case, the "SELECT" and "FROM" clauses
  # should be in uppercase in order to be autodetected.
  #
  # Implementing this method is optional, but may be necessary for certain
  # features (like `Last-Modified` response headers) to work.
  #
  # @param options [Hash] Empty hash.
  # @return [String, nil]
  #
  def jdbcsource_last_modified(options = {})
  end

  ##
  # Returns either the media (MIME) type of an image, or an SQL statement that
  # can be used to retrieve it from a `CHAR`-type column in the database. In
  # the latter case, the "SELECT" and "FROM" clauses should be in uppercase in
  # order to be autodetected. If nil is returned, the media type will be
  # inferred some other way, such as by identifier extension or magic bytes.
  #
  # @param options [Hash] Empty hash.
  # @return [String, nil]
  #
  def jdbcsource_media_type(options = {})
  end

  ##
  # @param options [Hash] Empty hash.
  # @return [String] SQL statement that selects the BLOB corresponding to the
  #                  value returned by `jdbcsource_database_identifier()`.
  #
  def jdbcsource_lookup_sql(options = {})
  end

  ##
  # N.B.: this method should not try to perform authorization. `authorize()`
  # should be used instead.
  #
  # @param options [Hash] Empty hash.
  # @return [Hash<String,Object>,nil] Hash containing `bucket` and `key` keys.
  #         It may also contain an `endpoint` key, indicating that the endpoint
  #         is different from the one set in the configuration. In that case,
  #         it may also contain `region`, `access_key_id`, and/or
  #         `secret_access_key` keys.
  #
  def s3source_object_info(options = {})
    logger = Java::edu.illinois.library.cantaloupe.delegate.Logger
    file_uri = URI(context['identifier'])
    out = { 'bucket' => file_uri.host, 'key' => file_uri.path[1..-1]}
    logger.debug "s3source hash: #{out}"
    out
  end

  ##
  # Tells the server what overlay, if any, to apply to an image. Called upon
  # all image requests to any endpoint if overlays are enabled and the overlay
  # strategy is set to `ScriptStrategy` in the application configuration.
  #
  # Return values:
  #
  # 1. For string overlays, a hash with the following keys:
  #     * `background_color` [String] CSS-compliant RGA(A) color.
  #     * `color`            [String] CSS-compliant RGA(A) color.
  #     * `font`             [String] Font name. Launch with the -list-fonts
  #                          argument to see a list of available fonts.
  #     * `font_min_size`    [Integer] Minimum font size in points (ignored
  #                          when `word_wrap` is true).
  #     * `font_size`        [Integer] Font size in points.
  #     * `font_weight`      [Float] Font weight based on 1.
  #     * `glyph_spacing`    [Float] Glyph spacing based on 0.
  #     * `inset`            [Integer] Pixels of inset.
  #     * `position`         [String] Position like `top left`, `center right`,
  #                          etc.
  #     * `string`           [String] String to draw.
  #     * `stroke_color`     [String] CSS-compliant RGB(A) text outline color.
  #     * `stroke_width`     [Float] Text outline width in pixels.
  #     * `word_wrap`        [Boolean] Whether to wrap long lines within
  #                          `string`.
  # 2. For image overlays, a hash with the following keys:
  #     * `image`    [String] Image pathname or URL.
  #     * `position` [String] See above.
  #     * `inset`    [Integer] See above.
  # 3. nil for no overlay.
  #
  # @param options [Hash] Empty hash.
  # @return See above.
  #
  def overlay(options = {})
  end

  ##
  # Tells the server what regions of an image to redact in response to a
  # particular request. Will be called upon all image requests to any endpoint.
  #
  # @param options [Hash] Empty hash.
  # @return [Array<Hash<String,Integer>>] Array of hashes, each with `x`, `y`,
  #         `width`, and `height` keys; or an empty array if no redactions are
  #         to be applied.
  #
  def redactions(options = {})
    []
  end

  ##
  # Returns XMP metadata to embed in the derivative image.
  #
  # Source image metadata is available in the `metadata` context key, and has
  # the following structure:
  #
  # ```
  # {
  #     "exif": {
  #         "tagSet": "Baseline TIFF",
  #         "fields": {
  #             "Field1Name": value,
  #             "Field2Name": value,
  #             "EXIFIFD": {
  #                 "tagSet": "EXIF",
  #                 "fields": {
  #                     "Field1Name": value,
  #                     "Field2Name": value
  #                 }
  #             }
  #         }
  #     },
  #     "iptc": [
  #         "Field1Name": value,
  #         "Field2Name": value
  #     ],
  #     "xmp_string": "<rdf:RDF>...</rdf:RDF>",
  #     "xmp_model": See https://jena.apache.org/documentation/javadoc/jena/org/apache/jena/rdf/model/Model.html,
  #     "xmp_elements": {
  #         "Field1Name": "value",
  #         "Field2Name": [
  #             "value1",
  #             "value2"
  #         ]
  #     },
  #     "native": {
  #         # structure varies
  #     }
  # }
  # ```
  #
  # * The `exif` key refers to embedded EXIF data. This also includes IFD0
  #   metadata from source TIFFs, whether or not an EXIF IFD is present.
  # * The `iptc` key refers to embedded IPTC IIM data.
  # * The `xmp_string` key refers to raw embedded XMP data.
  # * The `xmp_model` key contains a Jena Model object pre-loaded with the
  #   contents of `xmp_string`.
  # * The `xmp_elements` key contains a view of the embedded XMP data as key-
  #   value pairs. This is convenient to use, but may not work correctly with
  #   all XMP fields--in particular, those that cannot be expressed as
  #   key-value pairs.
  # * The `native` key refers to format-specific metadata.
  #
  # Any combination of the above keys may be present or missing depending on
  # what is available in a particular source image.
  #
  # Only XMP can be embedded in derivative images. See the user manual for
  # examples of working with the XMP model programmatically.
  #
  # @return [String,Model,nil] String or Jena model containing XMP data to
  #                            embed in the derivative image, or nil to not
  #                            embed anything.
  #
  def metadata(options = {})
  end

end
