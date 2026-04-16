class AddStatusToDeals < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :status, :integer, null: false, default: 0
    add_index :deals, :status
  end
end
