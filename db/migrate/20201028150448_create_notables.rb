class CreateNotables < ActiveRecord::Migration[6.0]
  def change
    create_table :notables do |t|
      t.string :name
      t.string :type
      t.belongs_to :notebook, null: false, foreign_key: true

      t.timestamps
    end
  end
end
