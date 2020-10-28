class AddDescriptionToNotables < ActiveRecord::Migration[6.0]
  def change
    add_column :notables, :description, :text
  end
end
