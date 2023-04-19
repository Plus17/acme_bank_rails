class Account < ApplicationRecord
  monetize :balance_cents, numericality: {greater_than_or_equal_to: 0}, message: "balance must be greater than or equal to 0"

  belongs_to :user
  has_many :deposits
end
