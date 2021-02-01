class AddOrderIndexToNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :notes, :order_index, :integer
  end
end
