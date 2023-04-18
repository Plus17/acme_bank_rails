FactoryBot.define do
  factory :account do
    balance_cents { 0 }
    user
  end
end
