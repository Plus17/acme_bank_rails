require "test_helper"

class Api::V1::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "create an account with errors" do
    post api_v1_accounts_url, headers: {
      "Accept" => "application/json"
    }, params: {account: {user_id: ""}}

    assert_response 422

    parsed_response = JSON.parse(response.body)

    errors = {"errors" => {"user" => ["must exist"]}}

    assert_equal errors, parsed_response
  end

  test "create an account" do
    user = FactoryBot.create(:user)

    post api_v1_accounts_url, headers: {
      "Accept" => "application/json"
    }, params: {account: {user_id: user.id}}

    assert_response 201

    parsed_response = JSON.parse(response.body)

    assert_equal 0, parsed_response.dig("data", "account", "balance_cents")
    assert_equal "USD", parsed_response.dig("data", "account", "balance_currency")
    assert_equal user.id, parsed_response.dig("data", "account", "user_id")
  end
end
