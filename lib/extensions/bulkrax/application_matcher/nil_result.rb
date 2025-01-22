module Extensions
  module Bulkrax
    module ApplicationMatcher
      module NilResult
        # unmodified from bulkrax 5.5.1
        def result(_parser, content)
          return nil if self.excluded == true || ::Bulkrax.reserved_properties.include?(self.to)
          return nil if self.if && (!self.if.is_a?(::Array) && self.if.length != 2)
    
          if self.if
            return unless content.send(self.if[0], ::Regexp.new(self.if[1]))
          end
    
          # @result will evaluate to an empty string for nil content values
          @result = content.to_s.gsub(/\s/, ' ').strip # remove any line feeds and tabs
          # blank needs to be based to split, only skip nil
          process_split unless @result.nil?
          @result = @result[0] if @result.is_a?(::Array) && @result.size == 1
          process_parse
          return @result
        end
      end
    end
  end
end
