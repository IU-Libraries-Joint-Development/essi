module Extensions
  module AllinsonFlex
    module OptimizedAdminSetLookup
      # Original from AllinsonFlex::DynamicSchemaService
      def context_for(admin_set_id:)
        cxt = AdminSet.find(admin_set_id).metadata_context
        if cxt.blank?
          raise AllinsonFlex::NoAllinsonFlexContextError.new(
            "No Metadata Context for Admin Set #{admin_set_id}"
          )
        end
        @context = cxt.name
        @context_id = cxt.id
      end
    end
  end
end