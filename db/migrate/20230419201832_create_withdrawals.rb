class CreateWithdrawals < ActiveRecord::Migration[7.0]
  def change
    create_table :withdrawals, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.monetize :amount, null: false
      t.string :idempotency_key
      t.timestamps
    end

    add_index :withdrawals, :idempotency_key, unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
  		    ALTER TABLE withdrawals
	        ADD CONSTRAINT withdrawals_amount_must_greater_than_0
	        CHECK (amount_cents > 0)
        SQL

        execute <<-SQL
          CREATE OR REPLACE FUNCTION validate_withdrawal_amount()
          RETURNS TRIGGER AS $$
          BEGIN
            IF NEW.amount_cents > (SELECT balance_cents FROM accounts WHERE id = NEW.account_id) THEN
              RAISE EXCEPTION 'Withdrawal amount is greater than account balance';
            END IF;
            RETURN NEW;
          END;
          $$ LANGUAGE plpgsql;
        SQL

        execute <<-SQL
          CREATE TRIGGER withdrawal_amount_validation
          BEFORE INSERT ON withdrawals
          FOR EACH ROW EXECUTE FUNCTION validate_withdrawal_amount();
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE withdrawals
          DROP CONSTRAINT withdrawals_amount_must_greater_than_0
        SQL

        execute <<-SQL
          ALTER TABLE withdrawals
          DROP CONSTRAINT check_withdrawal_amount
        SQL
      end
    end
  end
end
