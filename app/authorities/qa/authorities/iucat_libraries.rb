module Qa::Authorities
  class IucatLibraries < Base
    include WebServiceBase

    def search(id)
      all_data.select { |library| library[:code].match(id.to_s) }
    end

    def find(id)
      all_data.select { |e| e[:code] == id }.first || {}
    end

    def all
      all_data
    end

    def reload_data!
      reload_data_from_api!
      @holding_location_data = nil
      @supplemental_data = nil
    end

    private
      def api_url(id)
        return nil unless ESSI.config[:iucat_libraries]
        [ESSI.config[:iucat_libraries][:url], ::Addressable::URI.escape(id)].join('/')
      end

      def api_data_for(id)
        return {} unless api_enabled? && api_url(id)
        begin
          result = json(api_url(id)).with_indifferent_access
          result[:success] ? filter_results(result[:data]) : {}
        rescue TypeError, JSON::ParserError, Faraday::ConnectionFailed, URI::InvalidURIError
          {}
        end
      end

      def api_enabled?
        return nil unless ESSI.config[:iucat_libraries]
        ESSI.config[:iucat_libraries][:api_enabled]
      end

      def filter_results(data)
        (data.dig(:libraries) || []).each do |library|
          data[:libraries].delete(library) if no_display?(library)
        end
        data
      end

      # counterintuitively, API no_display values of false equate to hidden from display
      # hide any libraries missing a label, regardless of no_display value
      def no_display?(library)
        library[:no_display].is_a?(FalseClass) || library[:label].blank?
      end

      def supplemental_data_for(id)
        supplemental_data.select { |e| e[:code] == id }.first
      end

      def supplemental_filepath
        Rails.root.join('config', 'authorities', 'supplemental_holding_locations.yml')
      end

      def supplemental_data
        @supplemental_data ||= begin
          YAML.load_file(supplemental_filepath).map { |h| h.with_indifferent_access }
        rescue
          []
        end
      end

      def holding_location_filepath
        Rails.root.join('config', 'authorities', 'holding_locations.yml')
      end

      def holding_location_data
        @holding_location_data ||= begin
          YAML.load_file(holding_location_filepath).map { |h| h.with_indifferent_access }
        rescue
          []
        end
      end

      def all_data
        (holding_location_data + supplemental_data).uniq { |r| r[:code] }.sort { |a,b| a[:label].to_s <=> b[:label].to_s }
      end

      def reload_data_from_api!
        new_data = api_data_for('all')[:libraries]
        # If new data is empty then it must be an error so don't overwrite the file removing the existing data
        return if new_data.blank?

        File.open(holding_location_filepath, 'w') do |file|
          file.write YAML.dump(new_data)
        end
      end
  end
end
