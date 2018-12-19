module Qa::Authorities
  class IucatLibraries < Base
    include WebServiceBase

    def search(id)
      all.select { |library| library[:code].match(id.to_s) }
    end

    def find(id)
      data_for(id)[:library] || {}
    end

    def all
      data_for('all')[:libraries] || []
    end

    private
      def api_url
        { development: 'http://iucat-feature-tadas.uits.iu.edu/api/library',
          test: 'http://iucat-feature-tadas.uits.iu.edu/api/library',
          production: 'http://iucat.iu.edu/api/library' }.with_indifferent_access[Rails.env]
      end

      def data_for(id)
        begin 
          result = json([api_url, id].join('/')).with_indifferent_access
          result[:success] ? result[:data] : {}
        rescue TypeError, JSON::ParserError, Faraday::ConnectionFailed
          {}
        end
      end
  end
end
