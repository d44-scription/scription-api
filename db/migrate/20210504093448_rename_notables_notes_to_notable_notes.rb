class RenameNotablesNotesToNotableNotes < ActiveRecord::Migration[6.1]
  def change
    rename_table :notables_notes, :notable_notes
  end
end
