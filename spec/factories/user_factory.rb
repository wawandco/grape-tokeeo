FactoryGirl.define do

  sequence(:name)  { |n| "name_#{n}" }
  sequence(:email) { |n| "email_#{n}@test.com" }
  sequence(:token)  { |n| "#{SecureRandom.uuid}"}

  factory :user_active_record, class: User do |user|
    name; email; token
  end

  factory :user_data_mapper, class: UserDataMapper do
    name; email; token
  end

  factory :user_mongo_mapper, class: UserMongoMapper do
    name; email; token
  end
end
