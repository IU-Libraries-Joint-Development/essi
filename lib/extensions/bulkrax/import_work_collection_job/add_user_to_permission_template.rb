module Extensions
  module Bulkrax
    module ImportWorkCollectionJob
      module AddUserToPermissionTemplate
        private

        # modified from bulkrax to allow existing PermissionTemplateAccess
        def add_user_to_permission_template!(entry)
          user                = ::User.find(entry.importerexporter.user_id)
          collection          = entry.factory.find
          permission_template = ::Hyrax::PermissionTemplate.find_or_create_by!(source_id: collection.id)
    
          ::Hyrax::PermissionTemplateAccess.find_or_create_by!(
            permission_template_id: permission_template.id,
            agent_id: user.user_key,
            agent_type: 'user',
            access: 'manage'
          )
    
          collection.reset_access_controls!
        end
      end
    end
  end
end
