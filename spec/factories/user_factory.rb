FactoryGirl.define do
  factory :user do |user|
    sequence(:name) { |n| "name_#{n}" }
    sequence(:email) { |n| "email_#{n}@test.com" }
    token "#{SecureRandom.uuid}"
  end

  factory :user_data_mapper, class: UserDataMapper do
    sequence(:name)  { |n| "name_#{n}" }
    sequence(:email) { |n| "email_#{n}"}
    token "#{SecureRandom.uuid}"
  end
end
