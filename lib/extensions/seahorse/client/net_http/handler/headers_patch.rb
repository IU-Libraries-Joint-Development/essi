# unmodified from aws-sdk-core:3.131.1
module Extensions
  module Seahorse
    module Client
      module NetHttp
        module Handler
          module HeadersPatch
            def headers(request)
              # Net::HTTP adds a default header for accept-encoding (2.0.0+).
              # Setting a default empty value defeats this.
              #
              # Removing this is necessary for most services to not break request
              # signatures as well as dynamodb crc32 checks (these fail if the
              # response is gzipped).
              headers = { 'accept-encoding' => '' }
              request.headers.each_pair do |key, value|
                headers[key] = value
              end
              headers
            end
          end
        end
      end
    end
  end
end
