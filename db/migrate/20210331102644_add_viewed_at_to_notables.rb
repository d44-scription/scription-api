class AddViewedAtToNotables < ActiveRecord::Migration[6.1]
  def change
    add_column :notables, :viewed_at, :datetime, default: DateTime.now
  end
end
