class CreateDeposits < ActiveRecord::Migration[7.0]
  def change
    create_table :deposits, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.monetize :amount, null: false
      t.string :idempotency_key, null: false

      t.timestamps
    end

    add_index :deposits, :idempotency_key, unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
		  ALTER TABLE deposits
	      ADD CONSTRAINT deposits_amount_must_greater_than_0
	      CHECK (amount_cents > 0)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE deposits
          DROP CONSTRAINT deposits_amount_must_greater_than_0
        SQL
      end
    end
  end
end
