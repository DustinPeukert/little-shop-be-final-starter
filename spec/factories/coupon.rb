FactoryBot.define do
  factory :coupon do
    name { Faker::Alphanumeric.alpha(number: 6).upcase }
    code { Faker::Commerce.promotion_code }
    discount_type { ["dollar_off", "percent_off"].sample }
    discount_value { rand(1..100) }
    status { "inactive" }
    merchant
  end
end