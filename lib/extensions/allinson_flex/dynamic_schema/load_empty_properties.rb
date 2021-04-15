# frozen_string_literal: true

module Extensions
  module AllinsonFlex
    module DynamicSchema
      module LoadEmptyProperties
        def schema
          return_value = self[:schema]
          return_value['properties'] ||= {}
          return_value
        end
      end
    end
  end
end
