class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.text :contents
      t.belongs_to :notebook, null: false, foreign_key: true

      t.timestamps
    end
  end
end
