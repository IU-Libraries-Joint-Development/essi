# front-facing methods methods
#

# update sharing permissions for email change, then user record
def update_user_email(old_email, new_email, batch_size: 10, while_loop_limit: 100_000)
  user = User.find_by_email(old_email)
  return unless user

  # update work permissions
  i = 0
  work_ids = manageable_work_ids_for(old_email, rows: batch_size)
  while work_ids.any? && (i += batch_size) < while_loop_limit
    work_ids.each do |work_id|
      work = ActiveFedora::Base.find(work_id)
      update_work_permissions(work, old_email, new_email)
    end
    work_ids = manageable_work_ids_for(old_email, rows: batch_size)
  end

  if i < while_loop_limit
    user.email = new_email
    user.save
    # @todo log completion
  else
    # @todo log incomplete action, need to re-run
  end
end

# logic differs from copy, remove actions since while loop activity does not remove existing permissions
def copy_user_permissions(old_email, new_email, while_loop_limit: 100_000)
  work_ids = manageable_work_ids_for(old_email, rows: while_loop_limit)
  unless work_ids.size < while_loop_limit
    # @todo log excessive permissions count
    return
  end

  work_ids.each do |work_id|
    work = ActiveFedora::Base.find(work_id)
    copy_work_permissions(work, old_email, new_email)
  end
end

def remove_user_permissions(old_email, batch_size: 10, while_loop_limit: 100_000)
  i = 0
  work_ids = manageable_work_ids_for(old_email, rows: batch_size)
  while work_ids.any? && (i += batch_size) < while_loop_limit
    work_ids.each do |work_id|
      work = ActiveFedora::Base.find(work_id)
      remove_work_permissions(work, old_email)
    end
    work_ids = manageable_work_ids_for(old_email, rows: batch_size)
  end

  if i < while_loop_limit
    # @todo log successful completion
  else
    # @todo log limit reached, need to re-run
  end
end 

# helper methods
#

# creates equivalent new permissions, removes old permissions
def update_work_permissions(work, old_name, new_name)
  work.permissions.each do |permission|
    replace_permission(work, permission, old_name, new_name) if permission.inspect.match(old_name)
  end
end

# creates equivalent new permissions
def copy_work_permissions(work, old_name, new_name)
  work.permissions.each do |permission|
    copy_permission(work, permission, old_name, new_name) if permission.inspect.match(old_name)
  end
end

# removes old permissions
def remove_work_permissions(work, old_name)
  work.permissions.each do |permission|
    remove_permission(work, permission, old_name) if permission.inspect.match(old_name)
  end
end

# creates equivalent new permission, removes old permission
def replace_permission(work, permission, old_name, new_name)
  permission_action(:replace, work, permission, old_name, new_name)
end

# creates equivalent new permission
def copy_permission(work, permission, old_name, new_name)
  permission_action(:copy, work, permission, old_name, new_name)
end

# removes old permission
def remove_permission(work, permission, old_name)
  permission_action(:remove, work, permission, old_name)
end

# core methods
#

# actions: remove, copy, replace
def permission_action(action, work, permission, old_name, new_name = nil)
  return unless action.in? [:remove, :copy, :replace]

  if action.in? [:copy, :replace]
    return unless new_name
    return unless permission_to_hash(permission)['name'] == old_name
    new_permission = replacement_permission(permission, new_name)
    return unless new_permission.is_a? Hash
    return unless new_permission.dig('permissions_attributes', '0', 'name') == new_name

    # add new permission  
    work.attributes = new_permission
    work.save!
    work.reload
  end

  # destroy old permission
  if action.in? [:remove, :replace] 
    permission.destroy
    work.save!
    work.reload
  end
end

# returns an equivalent permission, swapping in new name
def replacement_permission(permission, new_name)
   new_hash = permission_to_hash(permission)
   return unless new_hash

   new_hash['name'] = new_name
   # { 'permissions_attributes' => { '0' => { 'type' => type, 'name' => new_name, 'access' => access } } }
   { 'permissions_attributes' => { '0' => new_hash } }
end

def permission_to_hash(permission)
   agent = permission.agent.first.rdf_subject.to_s.inspect if permission.agent.first
   mode = permission.mode.first.rdf_subject.to_s.inspect if permission.mode.first
   return unless agent && mode
   type, name = agent.split('/').last.gsub('"', '').split('#')
   case mode
   when /Read/
     access = 'read'
   when /Write/
     access = 'edit'
   else
     access = nil
   end
   return unless access

   { 'type' => type, 'name' => name, 'access' => access }
end

# querying methods
#

def manageable_works_for(name, rows: 10)
  ids = manageable_work_ids_for(name, rows: rows)
  ActiveFedora::Base.find(ids)
end

def manageable_work_ids_for(name, rows: 10)
  manageable_work_docs_for(name, rows: 10).map(&:id)
end

def manageable_work_docs_for(name, rows: 10)
  controller = Hyrax::My::WorksController.new
  repository = controller.repository
  solr_path = controller.blacklight_config.solr_path
  solr_params = solr_params_for_manageable_works_for(name, rows: rows)
  response = repository.send_and_receive(solr_path, solr_params)
  response.docs
end

def solr_params_for_manageable_works_for(name, rows: 10)
  {"qt"=>"search", "facet.field"=>["visibility_ssi", "suppressed_bsi", "resource_type_sim", "admin_set_sim", "member_of_collections_ssim"], "facet.query"=>[], "facet.pivot"=>[], "fq"=>["({!terms f=edit_access_group_ssim}public) OR edit_access_person_ssim:#{name} OR read_access_person_ssim:#{name}", "{!terms f=has_model_ssim}Image,BibRecord,PagedResource,Scientific,ArchivalMaterial", "-_query_:\"{!raw f=depositor_ssim}#{name}\""], "hl.fl"=>[], "rows"=>rows, "qf"=>"title_tesim description_tesim abstract_tesim creator_tesim keyword_tesim ocr_text_tesi word_boundary_tsi all_text_timv", "facet"=>true, "f.visibility_ssi.facet.limit"=>6, "f.resource_type_sim.facet.limit"=>6, "f.admin_set_sim.facet.limit"=>6, "f.member_of_collections_ssim.facet.limit"=>6, "sort"=>"score desc, system_create_dtsi desc"}
end
