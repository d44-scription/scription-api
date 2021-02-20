# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
puts("Creating User")
user = User.create(email: 'admin@example.com', password: 'superSecret123!', password_confirmation: 'superSecret123!')

3.times do |i|
  puts("  Creating notebook #{i}")
  notebook = user.notebooks.create!(name: "Notebook #{i}", summary: "This here is a brief summary for notebook #{i}")

  puts("    Creating item for #{notebook.name}")
  item = notebook.items.create!(name: "Item #{i}")

  puts("    Creating character for #{notebook.name}")
  character = notebook.characters.create!(name: "Character #{i}")

  puts("    Creating location for #{notebook.name}")
  location = notebook.locations.create!(name: "Location #{i}")

  puts("    Creating linked notes for #{notebook.name}")
  notebook.notes.create!(content: "Test note #{i}. #{item.text_code} is owned by #{character.text_code}")
  notebook.notes.create!(content: "Test note #{i}. #{character.text_code} lives in #{location.text_code}")
  notebook.notes.create!(content: "Test note #{i}. #{item.text_code} is found in #{location.text_code}")
  notebook.notes.create!(content: "Test note #{i}. #{character.text_code} found #{item.text_code} in #{location.text_code}")
end
