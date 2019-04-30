module FileManagerFormExtensions
  delegate :viewing_direction, :viewing_hint, to: :model
end

Hyrax::Forms::FileManagerForm.class_eval do
  prepend FileManagerFormExtensions
end
