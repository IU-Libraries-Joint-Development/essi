# Imported from Hyrax and modified for FileSet-backed branding images
class CollectionBrandingInfo < ApplicationRecord

  def initialize(collection_id:,
                 filename:,
                 role:,
                 alt_txt: "",
                 target_url: "",
                 local_path: nil,
                 file_set_id: nil,
                 image_path: nil)

    super()
    self.collection_id = collection_id
    self.role = role
    self.alt_text = alt_txt
    self.target_url = target_url
    self.file_set_id = file_set_id
    self.image_path = image_path

    # the file is no longer stored at this location, but this is retained
    # for infrastructure for form field identifiers via local_path value
    self.local_path = local_path || find_local_filename(collection_id, role, filename)
  end

  def collection
    @collection ||= Collection.where(id: collection_id).first
  end

  def file_set
    @file_set ||= FileSet.find(file_set_id) if file_set_id.present?
  end

  def destroy
    file_set&.destroy
    super
  end

  def save(uploaded_file_id: nil, user_key: nil)
    if uploaded_file_id && user_key
      uploaded_file = uploaded_files(uploaded_file_id)
      user = User.find_by_user_key(user_key)
      attach_file_set(uploaded_file, user)
    end
    result = super()
    file_set&.save
    return result
  end

  def file_set_image_path
    @file_set_image_path ||= begin
      generate_image_path!
      image_path if image_path.present?
    end
  end

  def display_hash
    { file: file,
      full_path: local_path,
      relative_path: file_set_image_path,
      file_location: file_set_image_path,
      alttext: alt_text,
      linkurl: target_url }
  end

  private

    def attach_file_set(uploaded_file, user)
      actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
      uploaded_file.update(file_set_uri: actor.file_set.uri)
      self.file_set_id = actor.file_set.id
      actor.create_metadata()
      actor.create_content(uploaded_file)
    end

    # privatize image_path to require going through file_set_image_path
    def image_path
      self[:image_path]
    end

    def image_path=(val)
      write_attribute(:image_path, val)
    end

    def file
      File.split(local_path).last
    end
    
    def find_local_filename(collection_id, role, filename)
      local_dir = find_local_dir_name(collection_id, role)
      File.join(local_dir, filename)
    end
  
    def find_local_dir_name(collection_id, role)
      File.join(Hyrax.config.branding_path, collection_id.to_s, role.to_s)
    end  
    
    def generate_image_path!
      if image_path.blank? && iiif_path_service.lookup_id.present?
        self.image_path = iiif_path_service.iiif_image_url(size: ESSI.config.dig(:essi, :collection_banner_size))
        save
      end
    end  

    def uploaded_files(uploaded_file_ids)
      return [] if uploaded_file_ids.empty?
      Hyrax::UploadedFile.find(uploaded_file_ids)
    end

    def iiif_path_service
      @iiif_path_service ||= IIIFFileSetPathService.new(file_set || {})
    end
end
