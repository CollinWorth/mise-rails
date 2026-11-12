# Development sample data: three cooks and twenty public recipes with photos.
# Photo credits are in db/seeds/images/CREDITS.txt. Safe to run repeatedly.
return if Rails.env.production?

cooks = {
  "cook@example.com" => "Test Cook",
  "maria@example.com" => "Maria Lopez",
  "sam@example.com" => "Sam Okafor"
}.map do |email, name|
  User.find_or_create_by!(email_address: email) { |user| user.assign_attributes(name:, password: "secret123") }
end

# slug, name, cuisine, category, prep min, cook min, servings, ingredients ("qty|unit|name"), steps
RECIPES = [
  [ "spaghetti-carbonara", "Spaghetti Carbonara", "Italian", "Dinner", 10, 15, 4,
    %w[400|g|spaghetti 150|g|guanciale 4||egg\ yolks 1||egg 1|cup|pecorino\ romano 1|tsp|black\ pepper],
    [ "Boil the spaghetti in well-salted water until al dente.", "Crisp the guanciale in a cold pan over medium heat.", "Whisk yolks, egg, pecorino and pepper.", "Toss hot pasta with the guanciale off the heat, then stir in the egg mixture with a splash of pasta water until glossy." ] ],
  [ "margherita-pizza", "Margherita Pizza", "Italian", "Dinner", 90, 12, 2,
    %w[300|g|pizza\ dough 1/2|cup|crushed\ tomatoes 200|g|fresh\ mozzarella 1|handful|basil\ leaves 2|tbsp|olive\ oil],
    [ "Heat the oven as hot as it goes with a pizza stone inside.", "Stretch the dough into a 12 inch round.", "Top with tomatoes and torn mozzarella.", "Bake 10 to 12 minutes until blistered, then finish with basil and olive oil." ] ],
  [ "chicken-tikka-masala", "Chicken Tikka Masala", "Indian", "Dinner", 30, 40, 4,
    %w[700|g|chicken\ thighs 1|cup|yogurt 2|tbsp|garam\ masala 1||onion 3||garlic\ cloves 1|can|crushed\ tomatoes 1/2|cup|cream],
    [ "Marinate the chicken in yogurt and half the garam masala for at least 30 minutes.", "Broil the chicken until charred in spots.", "Sauté onion and garlic, add tomatoes and remaining spice, and simmer 15 minutes.", "Stir in cream and chicken and simmer 10 more minutes. Serve over rice." ] ],
  [ "beef-tacos", "Beef Tacos", "Mexican", "Dinner", 10, 15, 4,
    %w[500|g|ground\ beef 2|tbsp|taco\ seasoning 8||corn\ tortillas 1||tomato 1/2||onion 1|cup|shredded\ cheese 1||lime],
    [ "Brown the beef, drain, then stir in the seasoning and a splash of water.", "Warm the tortillas in a dry pan.", "Fill with beef, tomato, onion and cheese, and finish with lime juice." ] ],
  [ "pad-thai", "Pad Thai", "Thai", "Dinner", 20, 10, 3,
    %w[200|g|rice\ noodles 2||eggs 200|g|shrimp 3|tbsp|tamarind\ paste 2|tbsp|fish\ sauce 1|tbsp|sugar 1/2|cup|peanuts 1||lime],
    [ "Soak the noodles in warm water until pliable.", "Mix tamarind, fish sauce and sugar for the sauce.", "Stir-fry the shrimp, push aside, scramble the eggs, then add noodles and sauce.", "Serve with crushed peanuts and lime." ] ],
  [ "caesar-salad", "Caesar Salad", "American", "Lunch", 15, 0, 2,
    %w[1||romaine\ head 1/2|cup|parmesan 1|cup|croutons 1||egg\ yolk 1||garlic\ clove 2|tbsp|lemon\ juice 1/3|cup|olive\ oil],
    [ "Whisk yolk, mashed garlic and lemon juice, then stream in the oil.", "Toss torn romaine with the dressing.", "Top with parmesan and croutons." ] ],
  [ "guacamole", "Guacamole", "Mexican", "Snack", 10, 0, 4,
    %w[3||ripe\ avocados 1/2||red\ onion 1||jalapeño 1/4|cup|cilantro 2||limes 1/2|tsp|salt],
    [ "Mash the avocados with lime juice and salt, leaving some chunks.", "Fold in onion, jalapeño and cilantro.", "Taste and add more lime or salt." ] ],
  [ "banana-bread", "Banana Bread", "American", "Dessert", 15, 60, 8,
    %w[3||ripe\ bananas 1/3|cup|melted\ butter 3/4|cup|sugar 1||egg 1|tsp|baking\ soda 1\ 1/2|cup|flour 1|pinch|salt],
    [ "Heat the oven to 350°F and grease a loaf pan.", "Mash the bananas and stir in butter, sugar and egg.", "Fold in baking soda, salt and flour until just combined.", "Bake 60 minutes until a skewer comes out clean." ] ],
  [ "chocolate-chip-cookies", "Chocolate Chip Cookies", "American", "Dessert", 15, 11, 24,
    %w[1|cup|butter 3/4|cup|brown\ sugar 1/2|cup|sugar 2||eggs 2\ 1/4|cup|flour 1|tsp|baking\ soda 2|cup|chocolate\ chips],
    [ "Cream the butter and both sugars, then beat in the eggs.", "Stir in flour and baking soda, then the chips.", "Scoop onto trays and bake at 375°F for 9 to 11 minutes." ] ],
  [ "pancakes", "Fluffy Pancakes", "American", "Breakfast", 10, 15, 4,
    %w[1\ 1/2|cup|flour 1|tbsp|sugar 2|tsp|baking\ powder 1|cup|milk 1||egg 2|tbsp|melted\ butter],
    [ "Whisk the dry ingredients, then the wet ones, and combine with a few lumps left.", "Cook 1/4 cup scoops on a buttered griddle until bubbles form, then flip.", "Serve warm with syrup." ] ],
  [ "chicken-noodle-soup", "Chicken Noodle Soup", "American", "Dinner", 15, 35, 6,
    %w[2||chicken\ breasts 8|cup|chicken\ broth 3||carrots 3||celery\ stalks 1||onion 150|g|egg\ noodles],
    [ "Simmer chicken, vegetables and broth for 20 minutes.", "Shred the chicken and return it to the pot.", "Add noodles and cook until tender, about 8 minutes." ] ],
  [ "beef-stew", "Beef Stew", "American", "Dinner", 20, 150, 6,
    %w[1|kg|beef\ chuck 4||potatoes 3||carrots 1||onion 2|tbsp|tomato\ paste 4|cup|beef\ broth],
    [ "Brown the beef in batches.", "Cook the onion and tomato paste, then add broth and beef.", "Simmer covered for 90 minutes, add the vegetables, and simmer 45 minutes more." ] ],
  [ "vegetable-stir-fry", "Vegetable Stir-Fry", "Chinese", "Dinner", 15, 8, 3,
    %w[1||broccoli\ head 1||red\ bell\ pepper 2||carrots 3|tbsp|soy\ sauce 1|tbsp|sesame\ oil 2||garlic\ cloves],
    [ "Cut everything into bite-size pieces.", "Stir-fry the carrots and broccoli over high heat for 4 minutes.", "Add pepper and garlic for 2 minutes, then toss with soy sauce and sesame oil." ] ],
  [ "shakshuka", "Shakshuka", "Middle Eastern", "Breakfast", 10, 25, 3,
    %w[1||onion 1||red\ bell\ pepper 2||garlic\ cloves 1|can|crushed\ tomatoes 1|tsp|cumin 1|tsp|paprika 5||eggs],
    [ "Soften the onion and pepper, then add garlic and spices.", "Pour in the tomatoes and simmer 10 minutes.", "Make wells for the eggs, cover, and cook until the whites are set." ] ],
  [ "tomato-soup", "Tomato Soup", "American", "Lunch", 10, 30, 4,
    %w[1|can|whole\ tomatoes 1||onion 2||garlic\ cloves 2|cup|vegetable\ broth 1/4|cup|cream 2|tbsp|butter],
    [ "Cook the onion and garlic in butter until soft.", "Add tomatoes and broth and simmer 20 minutes.", "Blend smooth and stir in the cream." ] ],
  [ "apple-pie", "Apple Pie", "American", "Dessert", 40, 55, 8,
    %w[2||pie\ crusts 6||apples 3/4|cup|sugar 2|tbsp|flour 1|tsp|cinnamon 2|tbsp|butter],
    [ "Toss sliced apples with sugar, flour and cinnamon.", "Fill the bottom crust, dot with butter, and cover with the top crust.", "Bake at 425°F for 15 minutes, then 350°F for 40 minutes." ] ],
  [ "mac-and-cheese", "Mac and Cheese", "American", "Dinner", 10, 25, 4,
    %w[250|g|elbow\ macaroni 2|tbsp|butter 2|tbsp|flour 2|cup|milk 2|cup|cheddar],
    [ "Cook the macaroni until just tender.", "Melt butter, whisk in flour, then add milk and cook until thick.", "Melt in the cheddar and stir in the pasta." ] ],
  [ "fried-rice", "Egg Fried Rice", "Chinese", "Dinner", 10, 10, 3,
    %w[3|cup|cooked\ cold\ rice 2||eggs 1/2|cup|frozen\ peas 2||green\ onions 2|tbsp|soy\ sauce 1|tbsp|oil],
    [ "Scramble the eggs in hot oil and set aside.", "Fry the rice until it starts to crackle.", "Add peas, soy sauce and eggs, and finish with green onions." ] ],
  [ "lasagna", "Classic Lasagna", "Italian", "Dinner", 45, 60, 8,
    %w[12||lasagna\ noodles 500|g|ground\ beef 3|cup|marinara 2|cup|ricotta 3|cup|shredded\ mozzarella 1/2|cup|parmesan],
    [ "Brown the beef and stir in the marinara.", "Layer noodles, ricotta, meat sauce and mozzarella, repeating three times.", "Cover and bake at 375°F for 45 minutes, uncover for 15, and rest before slicing." ] ],
  [ "greek-salad", "Greek Salad", "Greek", "Lunch", 10, 0, 3,
    %w[4||tomatoes 1||cucumber 1/2||red\ onion 1/2|cup|kalamata\ olives 150|g|feta 3|tbsp|olive\ oil 1|tsp|oregano],
    [ "Chop the tomatoes, cucumber and onion into chunks.", "Add olives, dress with olive oil and oregano, and top with a slab of feta." ] ]
].freeze

RECIPES.each_with_index do |(slug, name, cuisine, category, prep, cook, servings, ingredients, steps), index|
  owner = cooks[index % cooks.size]
  next if owner.recipes.exists?(name:)

  recipe = owner.recipes.build(name:, cuisine:, category:, prep_time: prep, cook_time: cook, servings:, public: true, instructions: steps.join("\n"))
  ingredients.each_with_index do |line, position|
    quantity, unit, ingredient = line.split("|", 3)
    recipe.ingredients.build(name: ingredient, quantity: quantity.presence, unit: unit.presence, position:)
  end
  recipe.save!
  image = Rails.root.join("db/seeds/images/#{slug}.jpg")
  recipe.image.attach(io: image.open, filename: "#{slug}.jpg", content_type: "image/jpeg") if image.exist?
end

# A few likes, follows and ratings so Discover and the follower lists have something to show.
cooks.each { |cook| (cooks - [ cook ]).each { |other| cook.follows.find_or_create_by!(followed: other) } }
Recipe.published.limit(10).each_with_index do |recipe, index|
  cooks.each { |cook| cook.likes.find_or_create_by!(recipe:) if cook != recipe.user && (index + cook.id).even? }
end
