class WithdrawalCreator
  def create_withdrawal(withdrawal)
    exist_withdrawal = Withdrawal.find_by(idempotency_key: withdrawal.idempotency_key)

    if exist_withdrawal.present?
      return Result.new(created: true, withdrawal: withdrawal)
    end

    ActiveRecord::Base.transaction do
      withdrawal.save!
      withdrawal.account.decrement!(:balance_cents, withdrawal.amount_cents)

      Result.new(created: withdrawal.valid?, withdrawal: withdrawal)
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.message)
    Result.new(created: withdrawal.valid?, withdrawal: withdrawal)
  end

  class Result
    attr_reader :withdrawal
    def initialize(created:, withdrawal: nil)
      @created = created
      @withdrawal = withdrawal
    end

    def created?
      @created
    end
  end
end
