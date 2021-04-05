class RemoveOrderIndexFromNotables < ActiveRecord::Migration[6.1]
  def change
    remove_column :notables, :order_index
  end
end
