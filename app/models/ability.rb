class Ability
  include Hydra::Ability

  include Hyrax::Ability
  include AllinsonFlex::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]
  # Define any customized permissions here.
  def custom_permissions
    can %i[file_manager save_structure structure pdf], PagedResource
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
    if current_user.admin?
      can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy, :pdf], Role
      can :manage, :sidekiq_dashboard
    end
  end

  # bulkrax import
  def can_import_works?
    can_create_any_work?
  end

  # bulkrax export
  def can_export_works?
    current_user.admin? || can_manage_works?
  end

  def can_manage_works?
    @can_manage_works ||= begin
      managing_role = Sipity::Role.find_by(name: Hyrax::RoleRegistry::MANAGING)
      return false unless managing_role
      Hyrax::Workflow::PermissionQuery.scope_processing_agents_for(user: current_user).any? do |agent|
        agent.workflow_responsibilities.joins(:workflow_role)
             .where('sipity_workflow_roles.role_id' => managing_role.id).any?
      end
    end
  end

  # Modified method from blacklight-access_controls Blacklight::AccessControls::Ability
  # Grants registered status for authenticated visibility ("Institution") by ldap group membership, if so configured, and admins
  def user_groups
    return @user_groups if @user_groups

    @user_groups = default_user_groups
    @user_groups |= current_user.groups if current_user.respond_to? :groups
    @user_groups |= ['registered'] if current_user.authorized_patron? || current_user.admin?
    @user_groups
  end
end
