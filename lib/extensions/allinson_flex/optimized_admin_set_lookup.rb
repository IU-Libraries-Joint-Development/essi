module Extensions
  module AllinsonFlex
    module OptimizedAdminSetLookup
      private

      # Modified from AllinsonFlex::DynamicSchemaService to avoid fedora request
      def context_for(admin_set_id:)
        cxt = ::AllinsonFlex::Context.find_metadata_context_for(admin_set_id: admin_set_id)
        if cxt.blank?
          raise ::AllinsonFlex::NoAllinsonFlexContextError.new(
            "No Metadata Context for Admin Set #{admin_set_id}"
          )
        end
        @context = cxt.name
        @context_id = cxt.id
      end
    end
  end
end