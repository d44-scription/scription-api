# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
puts('Creating notebooks...')
3.times do |i|
  n = Notebook.create!(name: "Notebook #{i}")

  puts("  Creating default notes for #{n.name}")
  3.times do |j|
    n.notes.create!(content: "Test note #{i}:#{j}")
  end

  puts("  Creating default items for #{n.name}")
  3.times do |j|
    n.items.create!(name: "Item #{i}:#{j}")
  end
end
