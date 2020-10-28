class CreateNotables < ActiveRecord::Migration[6.0]
  def change
    create_table :notables do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
