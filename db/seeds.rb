# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
3.times do |i|
  puts("Creating notebook #{i}")
  n = Notebook.create!(name: "Notebook #{i}", summary: "This here is a brief summary for notebook #{i}")

  puts("  Creating notes for #{n.name}")
  3.times do |j|
    n.notes.create!(content: "Test note #{i} - #{j}")
  end

  puts("  Creating items for #{n.name}")
  3.times do |j|
    n.items.create!(name: "Item #{i}:#{j}")
  end

  puts("  Creating characters for #{n.name}")
  3.times do |j|
    n.characters.create!(name: "Character #{i}:#{j}")
  end

  puts("  Creating locations for #{n.name}")
  3.times do |j|
    n.locations.create!(name: "Location #{i}:#{j}")
  end
end
