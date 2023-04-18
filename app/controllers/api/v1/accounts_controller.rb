class Api::V1::AccountsController < ApiController
  def create
    account = Account.new(account_params)
    result = AccountCreator.new.create_account(account)

    if result.created?
      render json: {data: {account: result.account}}, status: 201
    else
      render json: {errors: result.account.errors}, status: 422
    end
  end

  private

  def account_params
    params.require(:account).permit(:user_id)
  end
end
