class AddSummaryToNotebooks < ActiveRecord::Migration[6.0]
  def change
    add_column :notebooks, :summary, :text
  end
end
