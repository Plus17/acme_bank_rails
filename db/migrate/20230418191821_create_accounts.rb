class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.monetize :balance, null: false, default: 0

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
		  ALTER TABLE accounts
	      ADD CONSTRAINT accounts_balance_must_be_positive
	      CHECK (balance_cents >= 0)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE accounts
          DROP CONSTRAINT accounts_balance_must_be_positive
        SQL
      end
    end
  end
end
