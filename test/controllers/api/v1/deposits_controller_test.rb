require "test_helper"

class Api::V1::DepositsControllerTest < ActionDispatch::IntegrationTest
  test "should create deposit" do
    account = FactoryBot.create(:account)
    idempotency_key = SecureRandom.uuid
    post api_v1_deposits_url, headers: {
      "Accept" => "application/json",
      "Idempotency-Key" => idempotency_key
    }, params: {deposit: {account_id: account.id, amount_cents: 200}}

    assert_response 201
    parsed_response = JSON.parse(response.body)

    assert_equal 200, parsed_response.dig("data", "deposit", "amount_cents")
    assert_equal "USD", parsed_response.dig("data", "deposit", "amount_currency")
    assert_equal account.id, parsed_response.dig("data", "deposit", "account_id")
    assert_equal idempotency_key, parsed_response.dig("data", "deposit", "idempotency_key")
  end

  test "should return error for invalid deposit" do
    account = FactoryBot.create(:account)
    post api_v1_deposits_url, headers: {
      "Accept" => "application/json",
      "Idempotency-Key" => SecureRandom.uuid
    }, params: {deposit: {account_id: account.id, amount_cents: -200}}

    assert_response :unprocessable_entity
    parsed_response = JSON.parse(response.body)

    errors = {"errors" => {"amount" => ["must be greater than 0"]}}

    assert_equal errors, parsed_response
  end

  test "should return success for existing idempotency key" do
    account = FactoryBot.create(:account)
    idempotency_key = SecureRandom.uuid
    post api_v1_deposits_url, headers: {
      "Accept" => "application/json",
      "Idempotency-Key" => idempotency_key
    }, params: {deposit: {account_id: account.id, amount_cents: 200}}

    assert_response 201
    assert_equal 200, account.reload.balance_cents

    post api_v1_deposits_url, headers: {
      "Accept" => "application/json",
      "Idempotency-Key" => idempotency_key
    }, params: {deposit: {account_id: account.id, amount_cents: 200}}

    assert_response 201
    assert_equal 200, account.reload.balance_cents # account balance should not change
    parsed_response = JSON.parse(response.body)

    assert_equal 200, parsed_response.dig("data", "deposit", "amount_cents")
    assert_equal "USD", parsed_response.dig("data", "deposit", "amount_currency")
    assert_equal account.id, parsed_response.dig("data", "deposit", "account_id")
    assert_equal idempotency_key, parsed_response.dig("data", "deposit", "idempotency_key")
  end
end
