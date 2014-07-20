# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :article do
    title "Article title"
    content "Article content"
    topic "Main"
    url "url"
  end
end
