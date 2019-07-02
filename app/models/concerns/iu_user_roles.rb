module IuUserRoles
  extend ActiveSupport::Concern

  def image_editor?
    roles.where(name: 'image_editor').exists?
  end

  def editor?
    roles.where(name: 'editor').exists?
  end

  def fulfiller?
    roles.where(name: 'fulfiller').exists?
  end

  def curator?
    roles.where(name: 'curator').exists?
  end

  def institution_patron?
    persisted? && !guest? && provider == "cas"
  end

  def authorized_patron?
    institution_patron? && (ESSI.config[:authorized_ldap_groups].blank? ||
                       authorized_ldap_member?)
  end

  def anonymous?
    !persisted?
  end
end
