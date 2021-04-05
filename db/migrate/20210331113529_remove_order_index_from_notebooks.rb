class RemoveOrderIndexFromNotebooks < ActiveRecord::Migration[6.1]
  def change
    remove_column :notebooks, :order_index
  end
end
