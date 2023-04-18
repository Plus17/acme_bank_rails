class AccountCreator
  def create_account(account)
    account.save

    if account.invalid?
      Result.new(created: false, account: account)
    end

    Result.new(created: account.valid?, account: account)
  end

  class Result
    attr_reader :account
    def initialize(created:, account: nil)
      @created = created
      @account = account
    end

    def created?
      @created
    end
  end
end
