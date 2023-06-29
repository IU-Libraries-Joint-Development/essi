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

# Create transient new objects for all registered work types. Attempts to work around failures to
# define methods for some properties when loading works (e.g. missing ocr_state)
unless ActiveRecord::Base.connection.migration_context.needs_migration?
  Hyrax.config.registered_curation_concern_types.each do |klass|
    klass.constantize.new
  end
end
