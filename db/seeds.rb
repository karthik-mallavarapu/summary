# Create categories
['national', 'world', 'business', 'sports', 'miscellaneous'].each do |topic|
  Category.create(name: topic)
end