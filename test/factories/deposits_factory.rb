FactoryBot.define do
  factory :deposit do
    amount_cents { 100 }
    idempotency_key { SecureRandom.uuid }
    account
  end
end
