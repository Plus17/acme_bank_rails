class Deposit < ApplicationRecord
  monetize :amount_cents, numericality: {greater_than: 0}, message: "amount must be greater than 0"

  validates :idempotency_key, presence: true, uniqueness: true
  validates :account, presence: true

  belongs_to :account
end
