class AddOrderIndexToNotables < ActiveRecord::Migration[6.1]
  def change
    add_column :notables, :order_index, :integer
  end
end
