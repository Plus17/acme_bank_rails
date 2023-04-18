require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "should validate numericality of balance" do
    user = create(:user)
    account = Account.new(user: user, balance: -100)
    assert_not account.valid?
    assert_includes account.errors.full_messages, "Balance must be greater than or equal to 0"
  end
end
