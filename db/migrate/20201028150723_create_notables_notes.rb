class CreateNotablesNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notables_notes do |t|
      t.belongs_to :notable, null: false, foreign_key: true
      t.belongs_to :note, null: false, foreign_key: true
    end
  end
end
