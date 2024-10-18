module FacetHelper
  def campus_label(value)
    CampusService.find(value)[:term] || ''
  end
end
