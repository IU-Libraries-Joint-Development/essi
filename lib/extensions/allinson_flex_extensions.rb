#  models
AdminSet.class_eval do
  include AllinsonFlex::AdminSetBehavior
end

Hyrax.config.registered_curation_concern_types.each do |klass|
  klass.constantize.prepend Extensions::AllinsonFlex::PrependWorkDynamicSchema
end

#  constructors
AllinsonFlex::AllinsonFlexConstructor.include Extensions::AllinsonFlex::IncludeAllinsonFlexConstructor

#  controllers
Hyrax::Admin::PermissionTemplatesController.prepend Extensions::AllinsonFlex::PrependPermissionTemplatesController
AllinsonFlex::ProfilesController.prepend Extensions::AllinsonFlex::PrependProfilesController

#  forms
Hyrax::Forms::AdminSetForm.prepend Extensions::AllinsonFlex::PrependAdminSetForm
Hyrax::Forms::PermissionTemplateForm.prepend Extensions::AllinsonFlex::PrependPermissionTemplateForm

# importers
AllinsonFlex::Importer.prepend Extensions::AllinsonFlex::PrependImporter

# profiles
AllinsonFlex::Profile.prepend Extensions::AllinsonFlex::PrependProfile

# profile properties
AllinsonFlex::ProfileProperty.include Extensions::AllinsonFlex::IncludeProfileProperty

# profile texts
AllinsonFlex::ProfileText.include Extensions::AllinsonFlex::IncludeProfileText

 # Recreate only the AdminSet, not the associated permission template that is still in the database.
 # (Instead of AdminSet.find_or_create_default_admin_set_id)
if AdminSet.count.zero?
   AdminSet.create id: AdminSet::DEFAULT_ID, title: Array.wrap(AdminSet::DEFAULT_TITLE)
 end
# recreate permission template if it's not in the database, after all
if ActiveRecord::Base.connection.table_exists?('permission_templates') && Hyrax::PermissionTemplate.count.zero?
  hascs = Hyrax::AdminSetCreateService.new(admin_set: AdminSet.first, creating_user: nil)
  pt = hascs.send :create_permission_template
  workflow = hascs.send :create_workflows_for, permission_template: pt
  access = hascs.send :create_default_access_for, permission_template: pt, workflow: workflow
end

# Create transient new objects for all registered work types. Attempts to work around failures to
# define methods for some properties when loading works (e.g. missing ocr_state)
unless ActiveRecord::Base.connection.migration_context.needs_migration?
  Hyrax.config.registered_curation_concern_types.each do |klass|
    klass.constantize.new
  end
end
