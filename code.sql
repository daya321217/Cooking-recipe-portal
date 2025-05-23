-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS recipe_portal;

-- Use the newly created database
USE recipe_portal;

-- Create the 'recipes' table
-- This table will store the main information about each recipe.
CREATE TABLE IF NOT EXISTS recipes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    instructions TEXT, -- Storing instructions as plain text, possibly line-separated
    preparation_time VARCHAR(50),
    cooking_time VARCHAR(50),
    servings VARCHAR(50),
    image_url VARCHAR(255), -- URL to an image of the recipe
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- New column for dietary preference
    dietary_preference ENUM('Vegetarian', 'Non-Vegetarian', 'Vegan') DEFAULT 'Non-Vegetarian'
);

-- Create the 'ingredients' table
-- This table will store individual ingredients for each recipe.
-- It has a foreign key 'recipe_id' linking it to the 'recipes' table.
-- ON DELETE CASCADE means if a recipe is deleted, its ingredients are also deleted.
CREATE TABLE IF NOT EXISTS ingredients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    quantity VARCHAR(100), -- e.g., '2', '1/2', 'a handful'
    unit VARCHAR(50),     -- e.g., 'cups', 'g', 'teaspoons'
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- Optional: Create a 'categories' table for recipe categorization
-- This allows grouping recipes (e.g., 'Desserts', 'Main Course', 'Breakfast').
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Optional: Create a junction table for a many-to-many relationship between recipes and categories
-- A recipe can belong to multiple categories, and a category can have multiple recipes.
CREATE TABLE IF NOT EXISTS recipe_categories (
    recipe_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (recipe_id, category_id), -- Composite primary key
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- NEW: Create a 'countries' table for country-wise categorization
CREATE TABLE IF NOT EXISTS countries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- NEW: Create a junction table for many-to-many relationship between recipes and countries
CREATE TABLE IF NOT EXISTS recipe_countries (
    recipe_id INT NOT NULL,
    country_id INT NOT NULL,
    PRIMARY KEY (recipe_id, country_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE
);


-- Insert some sample data into the 'recipes' table
-- Updated to include 'dietary_preference'
INSERT INTO recipes (name, description, instructions, preparation_time, cooking_time, servings, image_url, dietary_preference) VALUES
('Classic Tomato Pasta', 'A simple yet delicious pasta dish, perfect for a quick weeknight meal.', '1. Bring a large pot of salted water to a boil. Add pasta and cook according to package directions until al dente.\n2. While pasta cooks, heat olive oil in a large skillet over medium heat. Add minced garlic and cook for 1 minute until fragrant.\n3. Add chopped tomatoes (fresh or canned diced tomatoes) to the skillet. Simmer for 10-15 minutes, crushing tomatoes with a spoon, until sauce thickens.\n4. Drain pasta, reserving about 1/2 cup of pasta water. Add pasta to the skillet with the sauce. Toss to combine.\n5. If sauce is too thick, add a little reserved pasta water until desired consistency. Stir in fresh basil and Parmesan cheese. Serve hot.', '15 mins', '20 mins', '2-3', 'https://placehold.co/600x400/FFD700/000000?text=Tomato+Pasta', 'Vegetarian');

INSERT INTO recipes (name, description, instructions, preparation_time, cooking_time, servings, image_url, dietary_preference) VALUES
('Spicy Chicken Curry', 'A rich and flavorful chicken curry with a kick.', '1. Heat oil in a large pot. Add chopped onions and cook until softened.\n2. Add chicken pieces and brown on all sides. Remove chicken and set aside.\n3. In the same pot, add ginger-garlic paste and cook for 1 minute. Add curry powder, turmeric, cumin, and chili powder. Cook for another minute until fragrant.\n4. Stir in chopped tomatoes and a splash of water. Simmer until tomatoes break down and form a paste.\n5. Return chicken to the pot. Add coconut milk and bring to a simmer. Cover and cook for 20-25 minutes, or until chicken is cooked through.\n6. Garnish with fresh cilantro and serve with rice or naan.', '20 mins', '40 mins', '4', 'https://placehold.co/600x400/FF4500/FFFFFF?text=Chicken+Curry', 'Non-Vegetarian');

INSERT INTO recipes (name, description, instructions, preparation_time, cooking_time, servings, image_url, dietary_preference) VALUES
('Vegetable Stir-fry', 'A quick and healthy stir-fry packed with fresh vegetables.', '1. Heat oil in a wok or large skillet over high heat. Add chopped garlic and ginger; stir-fry for 30 seconds.\n2. Add broccoli florets and sliced carrots. Stir-fry for 3-4 minutes until slightly tender-crisp.\n3. Add bell peppers and snap peas. Stir-fry for another 2-3 minutes.\n4. In a small bowl, whisk together soy sauce, sesame oil, and a pinch of sugar. Pour over vegetables and toss to coat.\n5. Serve immediately with rice or noodles.', '10 mins', '15 mins', '2', 'https://placehold.co/600x400/8BC34A/FFFFFF?text=Veg+Stir-fry', 'Vegan'); -- Assuming no animal products in soy/sesame oil

INSERT INTO recipes (name, description, instructions, preparation_time, cooking_time, servings, image_url, dietary_preference) VALUES
('Lentil Soup', 'A hearty and nutritious vegan lentil soup.', '1. Sauté chopped onions, carrots, and celery in olive oil until softened.\n2. Add minced garlic and cook for 1 minute. Stir in dried lentils, vegetable broth, diced tomatoes, and spices (cumin, coriander, turmeric).\n3. Bring to a boil, then reduce heat and simmer for 25-30 minutes, or until lentils are tender.\n4. Season with salt and pepper. Serve hot with fresh parsley.', '10 mins', '30 mins', '4', 'https://placehold.co/600x400/8B4513/FFFFFF?text=Lentil+Soup', 'Vegan');

INSERT INTO recipes (name, description, instructions, preparation_time, cooking_time, servings, image_url, dietary_preference) VALUES
('Butter Chicken', 'Creamy and rich Indian butter chicken.', '1. Marinate chicken in yogurt and spices. Cook chicken in a pan until browned.\n2. In a separate pot, sauté onions, ginger, garlic, and spices. Add tomato puree and cook until thickened.\n3. Stir in cream and butter. Add cooked chicken and simmer until heated through. Garnish with cilantro.', '30 mins', '45 mins', '4', 'https://placehold.co/600x400/FFA07A/000000?text=Butter+Chicken', 'Non-Vegetarian');


-- Insert sample data into the 'ingredients' table for 'Classic Tomato Pasta' (recipe_id = 1, assuming it's the first insert)
INSERT INTO ingredients (recipe_id, name, quantity, unit) VALUES
(1, 'Pasta', '200', 'g'),
(1, 'Tomatoes', '2', 'medium'),
(1, 'Garlic', '2', 'cloves'),
(1, 'Olive Oil', '2', 'tbsp'),
(1, 'Fresh Basil', '1/4', 'cup'),
(1, 'Parmesan Cheese', 'to taste', 'grated');

-- Insert sample data into the 'ingredients' table for 'Spicy Chicken Curry' (recipe_id = 2, assuming it's the second insert)
INSERT INTO ingredients (recipe_id, name, quantity, unit) VALUES
(2, 'Chicken Thighs', '500', 'g'),
(2, 'Onion', '1', 'large'),
(2, 'Ginger-Garlic Paste', '1', 'tbsp'),
(2, 'Curry Powder', '2', 'tbsp'),
(2, 'Coconut Milk', '400', 'ml'),
(2, 'Cilantro', '1/4', 'cup');

-- Insert sample data into the 'ingredients' table for 'Vegetable Stir-fry' (recipe_id = 3)
INSERT INTO ingredients (recipe_id, name, quantity, unit) VALUES
(3, 'Broccoli', '1', 'head'),
(3, 'Carrots', '2', 'medium'),
(3, 'Bell Peppers', '1', 'large'),
(3, 'Snap Peas', '100', 'g'),
(3, 'Soy Sauce', '3', 'tbsp'),
(3, 'Sesame Oil', '1', 'tsp'),
(3, 'Garlic', '2', 'cloves'),
(3, 'Ginger', '1', 'inch');

-- Insert sample data for 'Lentil Soup' (recipe_id = 4)
INSERT INTO ingredients (recipe_id, name, quantity, unit) VALUES
(4, 'Lentils', '1', 'cup'),
(4, 'Onion', '1', 'medium'),
(4, 'Carrots', '2', 'medium'),
(4, 'Celery', '2', 'stalks'),
(4, 'Vegetable Broth', '6', 'cups'),
(4, 'Diced Tomatoes', '1', 'can'),
(4, 'Cumin', '1', 'tsp'),
(4, 'Coriander', '1', 'tsp'),
(4, 'Turmeric', '0.5', 'tsp');

-- Insert sample data for 'Butter Chicken' (recipe_id = 5)
INSERT INTO ingredients (recipe_id, name, quantity, unit) VALUES
(5, 'Chicken Breast', '600', 'g'),
(5, 'Yogurt', '0.5', 'cup'),
(5, 'Tomato Puree', '1', 'cup'),
(5, 'Cream', '0.5', 'cup'),
(5, 'Butter', '4', 'tbsp'),
(5, 'Garam Masala', '1', 'tsp');


-- Optional: Insert sample categories
INSERT INTO categories (name) VALUES ('Italian'), ('Indian'), ('Vegetarian'), ('Non-Vegetarian'), ('Quick Meals'), ('Healthy');

-- Optional: Link recipes to categories
-- Classic Tomato Pasta (id=1) is Italian, Vegetarian, Quick Meal
INSERT INTO recipe_categories (recipe_id, category_id) VALUES
(1, (SELECT id FROM categories WHERE name = 'Italian')),
(1, (SELECT id FROM categories WHERE name = 'Vegetarian')),
(1, (SELECT id FROM categories WHERE name = 'Quick Meals'));

-- Spicy Chicken Curry (id=2) is Indian, Non-Vegetarian
INSERT INTO recipe_categories (recipe_id, category_id) VALUES
(2, (SELECT id FROM categories WHERE name = 'Indian')),
(2, (SELECT id FROM categories WHERE name = 'Non-Vegetarian'));

-- Vegetable Stir-fry (id=3) is Vegetarian, Quick Meals, Healthy
INSERT INTO recipe_categories (recipe_id, category_id) VALUES
(3, (SELECT id FROM categories WHERE name = 'Vegetarian')),
(3, (SELECT id FROM categories WHERE name = 'Quick Meals')),
(3, (SELECT id FROM categories WHERE name = 'Healthy'));

-- Lentil Soup (id=4) is Vegetarian, Vegan, Healthy
INSERT INTO recipe_categories (recipe_id, category_id) VALUES
(4, (SELECT id FROM categories WHERE name = 'Vegetarian')),
(4, (SELECT id FROM categories WHERE name = 'Healthy')); -- Vegan is handled by dietary_preference

-- Butter Chicken (id=5) is Indian, Non-Vegetarian
INSERT INTO recipe_categories (recipe_id, category_id) VALUES
(5, (SELECT id FROM categories WHERE name = 'Indian')),
(5, (SELECT id FROM categories WHERE name = 'Non-Vegetarian'));


-- NEW: Insert sample countries
INSERT INTO countries (name) VALUES ('Italy'), ('India'), ('China'), ('Mediterranean');

-- NEW: Link recipes to countries
INSERT INTO recipe_countries (recipe_id, country_id) VALUES
(1, (SELECT id FROM countries WHERE name = 'Italy')), -- Classic Tomato Pasta is Italian
(2, (SELECT id FROM countries WHERE name = 'India')), -- Spicy Chicken Curry is Indian
(3, (SELECT id FROM countries WHERE name = 'China')), -- Vegetable Stir-fry is Chinese
(4, (SELECT id FROM countries WHERE name = 'Mediterranean')), -- Lentil Soup (common in Med cuisine)
(5, (SELECT id FROM countries WHERE name = 'India')); -- Butter Chicken is Indian


-- --- ADVANCED QUERIES ---

-- 1. Get all recipes along with their ingredients
-- This query uses a JOIN to combine data from the 'recipes' and 'ingredients' tables.
-- It's useful for displaying a full recipe, including its components.
SELECT
    r.name AS recipe_name,
    r.description,
    r.instructions,
    r.preparation_time,
    r.cooking_time,
    r.servings,
    i.name AS ingredient_name,
    i.quantity,
    i.unit
FROM
    recipes r
JOIN
    ingredients i ON r.id = i.recipe_id
ORDER BY
    r.name, i.name;

-- 2. Find all recipes belonging to a specific category (e.g., 'Vegetarian')
-- This query uses multiple JOINs to link recipes to their categories through the junction table.
SELECT
    r.name AS recipe_name,
    c.name AS category_name
FROM
    recipes r
JOIN
    recipe_categories rc ON r.id = rc.recipe_id
JOIN
    categories c ON rc.category_id = c.id
WHERE
    c.name = 'Vegetarian'
ORDER BY
    r.name;

-- 3. Count the number of recipes in each category
-- This query uses JOIN and GROUP BY to count recipes per category.
-- It's useful for displaying category statistics.
SELECT
    c.name AS category_name,
    COUNT(r.id) AS number_of_recipes
FROM
    categories c
LEFT JOIN -- Use LEFT JOIN to include categories even if they have no recipes
    recipe_categories rc ON c.id = rc.category_id
LEFT JOIN
    recipes r ON rc.recipe_id = r.id
GROUP BY
    c.name
ORDER BY
    number_of_recipes DESC, c.name;

-- 4. Find recipes that have more than 5 ingredients
-- This query uses JOIN, GROUP BY, and HAVING to filter groups based on an aggregate condition.
SELECT
    r.name AS recipe_name,
    COUNT(i.id) AS total_ingredients
FROM
    recipes r
JOIN
    ingredients i ON r.id = i.recipe_id
GROUP BY
    r.id, r.name
HAVING
    total_ingredients > 5
ORDER BY
    total_ingredients DESC;

-- 5. Find ingredients that are used in more than one recipe
-- This query identifies common ingredients across multiple recipes.
SELECT
    name AS ingredient_name,
    COUNT(DISTINCT recipe_id) AS recipes_count
FROM
    ingredients
GROUP BY
    name
HAVING
    recipes_count > 1
ORDER BY
    recipes_count DESC, ingredient_name;

-- 6. Find recipes that do NOT belong to the 'Indian' category
-- This query uses a LEFT JOIN and checks for NULL in the joined table to find recipes
-- that have no association with the specified category.
SELECT
    r.name AS recipe_name
FROM
    recipes r
LEFT JOIN
    recipe_categories rc ON r.id = rc.recipe_id
LEFT JOIN
    categories c ON rc.category_id = c.id AND c.name = 'Indian'
WHERE
    c.id IS NULL -- This condition means there was no match for 'Indian' category
ORDER BY
    r.name;

-- 7. Get the total cooking time for all recipes (sum of cooking_time, assuming numeric)
-- This query attempts to sum a VARCHAR column. In a real application, 'cooking_time'
-- should ideally be an INT (e.g., minutes) for proper aggregation.
-- This example demonstrates how you *might* try it if time is stored as 'X mins'.
-- It would require string manipulation or casting, which is often better handled in application logic
-- if the format is inconsistent. For simplicity here, we'll assume it's numeric or we'll just count.
SELECT
    COUNT(id) AS total_recipes,
    GROUP_CONCAT(cooking_time SEPARATOR ', ') AS all_cooking_times -- Shows all times as a string
FROM
    recipes;

-- If cooking_time was stored as INT (e.g., minutes):
-- ALTER TABLE recipes MODIFY COLUMN cooking_time INT;
-- UPDATE recipes SET cooking_time = 20 WHERE name = 'Classic Tomato Pasta';
-- SELECT SUM(cooking_time) AS total_cooking_minutes FROM recipes;

-- 8. Find the most recently added recipe
SELECT
    id,
    name,
    created_at
FROM
    recipes
ORDER BY
    created_at DESC
LIMIT 1;

-- 9. List all categories and the recipes under each, even if a category has no recipes
-- This uses a LEFT JOIN starting from categories to ensure all categories are listed.
SELECT
    c.name AS category_name,
    GROUP_CONCAT(r.name ORDER BY r.name SEPARATOR ', ') AS recipes_in_category
FROM
    categories c
LEFT JOIN
    recipe_categories rc ON c.id = rc.category_id
LEFT JOIN
    recipes r ON rc.recipe_id = r.id
GROUP BY
    c.name
ORDER BY
    c.name;

-- --- NEW ADVANCED QUERIES FOR CATEGORIZATION ---

-- 10. Find all recipes that are 'Vegetarian'
SELECT
    id,
    name,
    dietary_preference
FROM
    recipes
WHERE
    dietary_preference = 'Vegetarian'
ORDER BY
    name;

-- 11. Find all recipes that are 'Vegan'
SELECT
    id,
    name,
    dietary_preference
FROM
    recipes
WHERE
    dietary_preference = 'Vegan'
ORDER BY
    name;

-- 12. Find all recipes that are 'Non-Vegetarian'
SELECT
    id,
    name,
    dietary_preference
FROM
    recipes
WHERE
    dietary_preference = 'Non-Vegetarian'
ORDER BY
    name;

-- 13. Get all recipes from a specific country (e.g., 'India')
-- This query uses JOINs to link recipes to their associated countries.
SELECT
    r.name AS recipe_name,
    c.name AS country_name,
    r.dietary_preference
FROM
    recipes r
JOIN
    recipe_countries rc ON r.id = rc.recipe_id
JOIN
    countries c ON rc.country_id = c.id
WHERE
    c.name = 'India'
ORDER BY
    r.name;

-- 14. Count the number of recipes per country
SELECT
    co.name AS country_name,
    COUNT(r.id) AS number_of_recipes
FROM
    countries co
LEFT JOIN
    recipe_countries rc ON co.id = rc.country_id
LEFT JOIN
    recipes r ON rc.recipe_id = r.id
GROUP BY
    co.name
ORDER BY
    number_of_recipes DESC, co.name;

-- 15. Find all 'Vegan' recipes from 'China'
-- This query combines filtering by dietary preference and country.
SELECT
    r.name AS recipe_name,
    r.dietary_preference,
    co.name AS country_name
FROM
    recipes r
JOIN
    recipe_countries rc ON r.id = rc.recipe_id
JOIN
    countries co ON rc.country_id = co.id
WHERE
    r.dietary_preference = 'Vegan' AND co.name = 'China'
ORDER BY
    r.name;

-- 16. List all dietary preferences and the count of recipes for each
SELECT
    dietary_preference,
    COUNT(id) AS number_of_recipes
FROM
    recipes
GROUP BY
    dietary_preference
ORDER BY
    number_of_recipes DESC;
