module LockWarningHelper
  def lock_warning(curation_concern)
    return nil unless curation_concern.try(:lock?)
    content_tag(:h1,
                'This object is currently queued for processing.',
                class: 'alert alert-warning')
  end
end

