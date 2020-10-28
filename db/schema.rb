# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_28_150723) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "notables", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notables_notes", force: :cascade do |t|
    t.bigint "notable_id", null: false
    t.bigint "note_id", null: false
    t.index ["notable_id"], name: "index_notables_notes_on_notable_id"
    t.index ["note_id"], name: "index_notables_notes_on_note_id"
  end

  create_table "notebooks", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notes", force: :cascade do |t|
    t.text "content"
    t.bigint "notebook_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["notebook_id"], name: "index_notes_on_notebook_id"
  end

  add_foreign_key "notables_notes", "notables"
  add_foreign_key "notables_notes", "notes"
  add_foreign_key "notes", "notebooks"
end
