require "test_helper"

class WithdrawalTest < ActiveSupport::TestCase
  test "should validate presence of account" do
    withdrawal = Withdrawal.new
    assert_not withdrawal.valid?
    assert_includes withdrawal.errors.full_messages, "Account can't be blank"
  end

  test "should validate presence of amount" do
    withdrawal = Withdrawal.new
    assert_not withdrawal.valid?
    assert_includes withdrawal.errors.full_messages, "Amount must be greater than 0"
  end

  test "should validate numericality of amount" do
    withdrawal = Withdrawal.new(amount: -100)
    assert_not withdrawal.valid?
    assert_includes withdrawal.errors.full_messages, "Amount must be greater than 0"
  end

  test "should validate presence of idempotency_key" do
    withdrawal = Withdrawal.new
    assert_not withdrawal.valid?
    assert_includes withdrawal.errors.full_messages, "Idempotency key can't be blank"
  end

  test "should belong to account" do
    withdrawal = Withdrawal.new
    assert_respond_to withdrawal, :account
  end

  test "should not allow withdrawal exceeding account balance" do
    account = FactoryBot.create(:account, balance: Money.new(1000))
    withdrawal = Withdrawal.new(account: account, amount: Money.new(1500))
    assert_not withdrawal.valid?
    assert_includes withdrawal.errors.full_messages, "Amount is greater than account balance"
  end
end
