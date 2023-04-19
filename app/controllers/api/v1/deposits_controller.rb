class Api::V1::DepositsController < ApiController
  def create
    deposit = Deposit.new(deposit_params.merge(idempotency_key: request.headers["Idempotency-Key"]))
    result = DepositCreator.new.create_deposit(deposit)

    if result.created?
      render json: {data: {deposit: result.deposit}}, status: 201
    else
      render json: {errors: result.deposit.errors}, status: 422
    end
  end

  private

  def deposit_params
    params.require(:deposit).permit(:account_id, :amount_cents)
  end
end
