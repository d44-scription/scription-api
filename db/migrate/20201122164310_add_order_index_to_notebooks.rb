class AddOrderIndexToNotebooks < ActiveRecord::Migration[6.0]
  def change
    add_column :notebooks, :order_index, :integer
  end
end
