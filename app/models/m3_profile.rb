class M3Profile < ApplicationRecord
  has_many :m3_contexts
  has_many :dynamic_schemas

  has_many :classes, class_name: 'M3ProfileClass', inverse_of: :m3_profile
  has_many :contexts, class_name: 'M3ProfileContext', inverse_of: :m3_profile
  has_many :properties, class_name: 'M3ProfileProperty', inverse_of: :m3_profile
  accepts_nested_attributes_for :classes, :contexts, :properties

  serialize :profile

  validates :classes, :contexts, :properties, presence: true
  validates :profile_version, uniqueness: true

  #after_save :check_profile_version

  def check_profile_version
    #if we already have this version, 
    #    compare the data,
    #    if it’s the same, 
    #      do nothing;
    #    if it’s different 
    #      return an error “This version already exists, 
    #        please increment the version number”
    #else
    #  update version attribute by 1
    #end
  end

  def latest_version?(profiles)
    newest_record = profiles.order("created_at").last
  end
end
