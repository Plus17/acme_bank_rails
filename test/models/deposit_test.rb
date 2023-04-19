require "test_helper"

class DepositTest < ActiveSupport::TestCase
  test "should validate presence of account" do
    deposit = Deposit.new
    assert deposit.invalid?
    assert_includes deposit.errors.full_messages, "Account can't be blank"
  end

  test "should validate numericality of amount" do
    deposit = Deposit.new(amount: -100)
    assert deposit.invalid?
    assert_includes deposit.errors.full_messages, "Amount must be greater than 0"
  end

  test "should validate presence of idempotency_key" do
    deposit = Deposit.new
    assert deposit.invalid?
    assert_includes deposit.errors.full_messages, "Idempotency key can't be blank"
  end

  test "should validate uniqueness of idempotency_key" do
    deposit = FactoryBot.create(:deposit)

    Deposit.new(idempotency_key: deposit.idempotency_key, amount: 100, account: deposit.account).tap do |deposit|
      assert deposit.invalid?
      assert_includes deposit.errors.full_messages, "Idempotency key has already been taken"
    end
  end

  test "should belong to account" do
    deposit = Deposit.new
    assert_respond_to deposit, :account
  end
end
