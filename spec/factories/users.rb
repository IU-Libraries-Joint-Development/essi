# We use modify instead of define because the actual factory is defined in hyrax/spec/factories
FactoryBot.modify do
  factory :user do
    sequence(:uid) { |n| "username#{n}" }
    sequence(:email) { |n| "email-#{srand}@test.com" }
    provider { 'cas' }

    factory :admin do
      roles { [Role.where(name: 'admin').first_or_create] }
    end

    factory :authorized_patron do
      # All CAS users are authorized patrons.
    end

    factory :image_editor do
      roles { [Role.where(name: 'image_editor').first_or_create] }
    end

    factory :editor do
      roles { [Role.where(name: 'editor').first_or_create] }
    end

    factory :fulfiller do
      roles { [Role.where(name: 'fulfiller').first_or_create] }
    end

    factory :curator do
      roles { [Role.where(name: 'curator').first_or_create] }
    end

    factory :complete_reviewer do
      email { 'complete@example.com' }
      roles { [Role.where(name: 'notify_complete').first_or_create] }
    end

    factory :takedown_reviewer do
      email { 'takedown@example.com' }
      roles { [Role.where(name: 'notify_takedown').first_or_create] }
    end
  end
end
