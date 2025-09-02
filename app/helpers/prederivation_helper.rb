module PrederivationHelper

  def work_root_name(filename)
    filename.split('/').last.split('-').first
  end

  def derivatives_folder_for(filename, type: '')
    return false unless root_derivatives_folder
    folders = Array.wrap(root_derivatives_folder)
    folders << type.downcase if path_includes_type?
    folders << work_root_name(filename) if path_includes_work_root_name?
    File.join(folders)
  end

  def pre_derived_file(filename, type: '', suffix: 'xml')
    if file_includes_type?
      pre_derived_filename = "#{File.basename(filename, '.*')}-#{type.downcase}.#{suffix}"
    else
      pre_derived_filename = "#{File.basename(filename, '.*')}.#{suffix}"
    end

    Rails.logger.info "Checking for #{pre_derived_filename} in #{type} folders."

    ungrouped_filename = File.join(root_derivatives_folder, type.downcase, 'ungrouped', pre_derived_filename)
    if ungrouped_file_path?(ungrouped_filename)
      pre_derived_file = ungrouped_filename
    else
      derivatives_folder = derivatives_folder_for(filename, type: type)
      pre_derived_file = File.join(derivatives_folder, pre_derived_filename)
    end

    return false unless File.exist?(pre_derived_file)

    Rails.logger.info "Using #{pre_derived_file} as #{type} file."
    pre_derived_file
  end

  def root_derivatives_folder
    ESSI.config.dig(:essi, :derivatives_folder)
  end

  def path_includes_type?
    ESSI.config.dig(:essi, :derivatives_type_subfolder)
  end

  def path_includes_work_root_name?
    ESSI.config.dig(:essi, :derivatives_work_subfolder)
  end

  def file_includes_type?
    ESSI.config.dig(:essi, :derivatives_type_suffix)
  end

  def ungrouped_file_path?(ungrouped_filename)
    return false unless File.exist?(ungrouped_filename)
    true
  end
end
