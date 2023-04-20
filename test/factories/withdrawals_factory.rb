FactoryBot.define do
  factory :withdrawal do
    amount_cents { 100 }
    idempotency_key { SecureRandom.uuid }
    association :account, balance_cents: 100
  end
end
