# Create categories
['national', 'world', 'business', 'sports', 'other'].each do |topic|
  Category.create(name: topic)
end