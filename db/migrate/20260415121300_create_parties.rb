class CreateParties < ActiveRecord::Migration[7.0]
  def change
    create_table :parties do |t|
      t.string  :name,    null: false
      t.string  :phone
      t.text    :address
      # PostgreSQL array — one party can be client + seller + buyer simultaneously
      # Valid values: "client", "seller", "buyer"
      t.string  :roles,   array: true, default: [], null: false

      t.timestamps
    end

    add_index :parties, :name
    # GIN index for fast array queries (e.g. WHERE 'client' = ANY(roles))
    add_index :parties, :roles, using: :gin
  end
end
