module ImageQC
  module ImageValidator
    class CustomizableImageValidator
      attr_reader :metadata_reader, :validations

      # Validations schema hash format:
      # Keys are property names, with corresponding methods in @metadata_reader
      # Values used for validation may be:
      # - a string or numeric literal, for a required value;
      #   (functionally equivalent equivalent to a single-valued Array)
      # - a single literal Range, for a range of allowed values
      # - an Array of literals, for a set of allowed values 
      #     Note that an empty Array is equivalent to not providing the rule at all,
      #     but may be useful for explicit clarity or overriding an inherited rule
      # - a Symbol, for a method name to use for validation (instead of literals)
      # - another validations schema Hash, for conditional validation (see below)
      #
      # Without a nested Hash as the value, a key/value pair runs a standalone rule, like:
      #   print_resolution: :validate_600dpi_minimum # calls the specified method name
      #   color_bit_depth: [1, 8, 24] # accepts a bit depth of 1, 8, or 24; rejects others
      # whereas a nested Hash may apply case-specific if/then logic, such as:
      #   color_bit_depth: { 1 => {}, 8 => {}, 24 => { icc_description: 'Adobe RGB (1998)' }
      # which would still accept only 1/8/24-bit values as in the previous rule, but also:
      # - for the 1-bit and 8-bit cases, apply no further rules (implied by the empty Hash)
      # - for the 24-bit case, apply the provided icc_description validation rule
      # 
      # Hashes of if-then rules may be nested to theoretically arbitrary depth
      DEFAULT_VALIDATIONS = { format: 'TIFF',
                              compression: ['No', 'None', ''],
                              page_count: [1],
                              horizontal_resolution: [],
                              vertical_resolution: [],
                              color_bit_depth: [1, 8, 24]
                            }

      def initialize(metadata_reader, validations: {})
        @metadata_reader = metadata_reader
        @validations = default_validations.merge(validations)
      end

      def default_validations
        self.class.const_get(:DEFAULT_VALIDATIONS) || {}
      end

      # Validation error messages, or an empty Array if none
      #
      # @return [String] invalidation error messages
      def validation_errors
        validate_properties(validations).select(&:present?)
      end

      private
 
        # Retrieves results of validation checks against supplied schema
        #
        # @param [Hash] 
        # @return [Array<Nil, String>] invalidation error messages, and nils for successes
        def validate_properties(property_validations)
          errors = []
          property_validations.each do |property, values|
            validator = to_validator(values)
            unless validator.empty?
              actual = metadata_reader.send(property)
              errors << validate_property(property, actual, validator)
              if values.is_a?(Hash) && values[actual].present?
                errors += validate_properties(values[actual])
              end
            end
          end
          errors
        end
 
        # Converts input into format usable as a validator:
        # - an Array or Range of valid values
        # - a Symbol of a validator method name
        #
        # @param values [Hash, String, Integer, Float, Array, Symbol] raw input
        # @return [Array, Range, Symbol] converted output
        def to_validator(values)
          case values
          when Hash
            values.keys
          when String, Integer, Float
            Array.wrap(values)
          when Array, Range, Symbol
            values
          else
            raise "Invalid values type #{values.class}: #{values}"
          end
        end
 
        # Validates a property given a method name or values list
        #
        # @param property [Symbol] the metadata reader property name
        # @param actual [anything] the metadata reader value
        # @param validator [Symbol, Array<String, Integer, Float>, Range] a method name for validation, or Array of valid values
        # @return [Nil, String] the invalidation message, if present
        def validate_property(property, actual, validator)
          return self.send(validator, property, actual) if validator.is_a? Symbol
          unless validator.empty? || validator.include?(actual)
            "#{property} was #{actual.blank? ? 'undefined' : actual} " \
            "but must be#{' one of' unless validator.one?}: #{validator.join(', ')}" 
          end
        end
    end
  end
end
