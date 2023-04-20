class Withdrawal < ApplicationRecord
  monetize :amount_cents, numericality: {greater_than: 0}, message: "amount must be greater than 0"

  belongs_to :account

  validates :idempotency_key, presence: true, uniqueness: true
  validates :account, presence: true
  validate :withdrawal_amount_less_than_account_balance

  private

  def withdrawal_amount_less_than_account_balance
    if amount_cents && account && amount_cents > account.balance_cents
      errors.add(:amount, "is greater than account balance")
    end
  end
end
