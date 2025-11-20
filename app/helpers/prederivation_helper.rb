module PrederivationHelper

  def derivatives_folders_for(filename, type: '', include_ungrouped: true)
    segments = filename.split('-')[0..-2] # drop final segment as file-specific
    folders = (1..segments.size).map { |i| segments[0..-i].join('-') }
    folders << 'ungrouped' if include_ungrouped
    folders.map { |folder| derivatives_folder_for(folder, type) }.uniq
  end

  def derivatives_folder_for(folder, type)
    segments = [root_derivatives_folder]
    segments << type.downcase if path_includes_type?
    segments << folder if path_includes_work_root_name?
    File.join(segments)
  end

  def pre_derived_file(filename, type: '', suffix: 'xml')
    file_basename = File.basename(filename, '.*')
    if file_includes_type?
      pre_derived_filename = "#{file_basename}-#{type.downcase}.#{suffix}"
    else
      pre_derived_filename = "#{file_basename}.#{suffix}"
    end

    folders = derivatives_folders_for(file_basename, type: type)
    Rails.logger.info "Checking for #{pre_derived_filename} in #{type} folders: #{folders.join(', ')}"
    files = folders.map { |f| File.join(f, pre_derived_filename) }
    pre_derived_file = files.select { |f| File.exist?(f) }.first

    if pre_derived_file
      Rails.logger.info "Using #{pre_derived_file} as #{type} file"
      pre_derived_file
    else
      Rails.logger.info "No pre-derived file found"
      false
    end
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
end
