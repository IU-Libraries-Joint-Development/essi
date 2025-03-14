module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include AllinsonFlex::AllinsonFlexHelper
  include AllinsonFlex::AllinsonFlexModifiedHelper
  include ::FacetHelper

  # override hyrax method
  # Which translations are available for the user to select
  # @return [Hash{String => String}] locale abbreviations as keys and flags as values
  def available_translations
    {
      'en' => 'English'
    }
  end
end
