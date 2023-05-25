class Api::V1::WithdrawalsController < ApiController
  def index
    if params[:account_id].blank?
      render json: {errors: {account_id: ["can't be blank"]}}, status: 422
    end

    withdrawals = Withdrawal.where(account_id: params[:account_id])

    render json: {data: {withdrawals: withdrawals}}, status: 200
  end

  def create
    withdrawal = Withdrawal.new(withdrawal_params.merge(idempotency_key: request.headers["Idempotency-Key"]))
    result = WithdrawalCreator.new.create_withdrawal(withdrawal)

    if result.created?
      render json: {data: {withdrawal: result.withdrawal}}, status: 201
    else
      render json: {errors: result.withdrawal.errors}, status: 422
    end
  end

  private

  def withdrawal_params
    params.require(:withdrawal).permit(:account_id, :amount_cents)
  end
end
