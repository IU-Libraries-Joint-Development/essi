# unmodified from bulkrax 5.5.1
module Extensions
  module Bulkrax
    module Entry
      module SingleMetadata
        def single_metadata
          content = content.content if content.is_a?(Nokogiri::XML::NodeSet)
          return unless content
          Array.wrap(content.to_s.strip).join('; ')
        end
      end
    end
  end
end
