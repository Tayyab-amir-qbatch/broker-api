class CreateDeals < ActiveRecord::Migration[7.0]
  def change
    create_table :deals do |t|
      t.date       :deal_date,         null: false
      t.references :client,            null: false, foreign_key: { to_table: :parties }
      t.references :seller,            null: false, foreign_key: { to_table: :parties }
      t.references :buyer,             null: true,  foreign_key: { to_table: :parties }
      t.string     :quality,           null: false
      t.integer    :bags,              null: false
      t.decimal    :rate,              null: false, precision: 10, scale: 2
      # 0 = percentage, 1 = fixed_per_bag
      t.integer    :commission_type,   null: false, default: 0
      # Stores either the % value (e.g. 0.5) or fixed rupees per bag (e.g. 30)
      t.decimal    :commission_value,  null: false, precision: 8, scale: 4
      t.decimal    :bill_amount,       null: false, precision: 12, scale: 2
      t.text       :notes

      t.timestamps
    end

    # Common query patterns
    add_index :deals, :deal_date
    add_index :deals, [:client_id, :deal_date]
  end
end
