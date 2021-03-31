# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_31_113529) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "notables", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.bigint "notebook_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.integer "order_index"
    t.datetime "viewed_at", default: "2021-03-31 10:36:42"
    t.index ["notebook_id"], name: "index_notables_on_notebook_id"
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
    t.text "summary"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notebooks_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "content"
    t.bigint "notebook_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_index"
    t.index ["notebook_id"], name: "index_notes_on_notebook_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "display_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "notables", "notebooks"
  add_foreign_key "notables_notes", "notables"
  add_foreign_key "notables_notes", "notes"
  add_foreign_key "notebooks", "users"
  add_foreign_key "notes", "notebooks"
end
