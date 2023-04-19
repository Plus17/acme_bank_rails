class DepositCreator
  def create_deposit(deposit)
    exist_deposit = Deposit.find_by(idempotency_key: deposit.idempotency_key)

    if exist_deposit.present?
      return Result.new(created: true, deposit: deposit)
    end

    ActiveRecord::Base.transaction do
      deposit.save!
      deposit.account.increment!(:balance_cents, deposit.amount_cents)

      Result.new(created: deposit.valid?, deposit: deposit)
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.message)
    Result.new(created: deposit.valid?, deposit: deposit)
  end

  class Result
    attr_reader :deposit
    def initialize(created:, deposit: nil)
      @created = created
      @deposit = deposit
    end

    def created?
      @created
    end
  end
end
