# app.py
# This Python Flask application acts as the backend server for your Recipe Portal.
# It connects to your MySQL database, handles API requests from the frontend,
# executes SQL queries, and returns data (usually JSON) to the frontend.

from flask import Flask, request, jsonify
import mysql.connector
from flask_cors import CORS # Used to allow cross-origin requests from your HTML file

app = Flask(__name__)
CORS(app) # Enable CORS for all routes. This is crucial for local development
          # where your HTML file might be served from a different origin (e.g., file://)
          # than your Flask app (e.g., http://127.0.0.1:5000).

# --- Database Configuration ---
# IMPORTANT: Replace these with your actual MySQL credentials.
# Make sure your MySQL server is running.
DB_CONFIG = {
    'host': 'localhost',
    'user': 'user_name',    
    'password': 'your_passwd', 
    'database': 'recipe_portal'
}

def get_db_connection():
    """
    Establishes and returns a connection to the MySQL database.
    Handles potential connection errors.
    """
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except mysql.connector.Error as err:
        # Improved error message for connection failures
        print(f"ERROR: Could not connect to MySQL database. Please check your DB_CONFIG "
              f"(host, user, password, database) and ensure MySQL server is running. Details: {err}")
        return None

# --- API Routes ---

@app.route('/api/recipes', methods=['GET'])
def get_recipes():
    """
    API endpoint to fetch all recipes from the database, with optional filters.
    Filters can be applied using query parameters:
    - country: Filter by country name (e.g., /api/recipes?country=India)
    - dietary_preference: Filter by dietary preference (e.g., /api/recipes?dietary_preference=Vegan)
    Returns a JSON array of recipe objects.
    """
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)
    try:
        # Start building the base query
        query = """
            SELECT
                r.id,
                r.name,
                r.description,
                r.image_url,
                r.dietary_preference,
                GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') AS countries
            FROM
                recipes r
            LEFT JOIN
                recipe_countries rc ON r.id = rc.recipe_id
            LEFT JOIN
                countries c ON rc.country_id = c.id
        """
        
        conditions = []
        params = []

        # Check for 'country' filter
        country_filter = request.args.get('country')
        if country_filter and country_filter != 'All': # 'All' will be a default option in frontend
            conditions.append("c.name = %s")
            params.append(country_filter)
        
        # Check for 'dietary_preference' filter
        dietary_preference_filter = request.args.get('dietary_preference')
        if dietary_preference_filter and dietary_preference_filter != 'All': # 'All' will be a default option in frontend
            conditions.append("r.dietary_preference = %s")
            params.append(dietary_preference_filter)

        # Add WHERE clause if conditions exist
        if conditions:
            query += " WHERE " + " AND ".join(conditions)
        
        # Group by recipe to handle multiple countries per recipe
        query += " GROUP BY r.id, r.name, r.description, r.image_url, r.dietary_preference ORDER BY r.name"

        # Execute the dynamic SQL query
        cursor.execute(query, tuple(params))
        recipes = cursor.fetchall()
        return jsonify(recipes), 200
    except mysql.connector.Error as err:
        # Improved error message for query failures
        print(f"ERROR: MySQL query failed when fetching all recipes. Details: {err}")
        return jsonify({"error": "Failed to fetch recipes"}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/recipes/<int:recipe_id>', methods=['GET'])
def get_recipe_detail(recipe_id):
    """
    API endpoint to fetch details for a single recipe, including its ingredients and countries.
    Returns a JSON object with recipe details, an array of ingredients, and an array of countries.
    SQL Queries:
        - SELECT * FROM recipes WHERE id = %s
        - SELECT name, quantity, unit FROM ingredients WHERE recipe_id = %s
        - SELECT c.name FROM countries c JOIN recipe_countries rc ON c.id = rc.country_id WHERE rc.recipe_id = %s
    """
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)
    try:
        # Fetch recipe details
        cursor.execute("SELECT * FROM recipes WHERE id = %s", (recipe_id,))
        recipe = cursor.fetchone()

        if recipe:
            # Fetch ingredients for the recipe
            cursor.execute("SELECT name, quantity, unit FROM ingredients WHERE recipe_id = %s", (recipe_id,))
            ingredients = cursor.fetchall()
            
            # Fetch countries for the recipe
            cursor.execute("""
                SELECT c.name
                FROM countries c
                JOIN recipe_countries rc ON c.id = rc.country_id
                WHERE rc.recipe_id = %s
            """, (recipe_id,))
            countries = [row['name'] for row in cursor.fetchall()] # Extract just the country names

            recipe['ingredients'] = ingredients # Add ingredients list to the recipe object
            recipe['countries'] = countries # Add countries list to the recipe object
            return jsonify(recipe), 200
        else:
            return jsonify({"error": "Recipe not found"}), 404
    except mysql.connector.Error as err:
        # Improved error message for query failures
        print(f"ERROR: MySQL query failed when fetching recipe detail for ID {recipe_id}. Details: {err}")
        return jsonify({"error": "Failed to fetch recipe detail"}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/recipes', methods=['POST'])
def add_recipe():
    """
    API endpoint to add a new recipe and its ingredients to the database.
    Expects JSON data in the request body.
    Returns the newly created recipe's ID or an error message.
    SQL Queries:
        - INSERT INTO recipes (...) VALUES (...)
        - INSERT INTO ingredients (...) VALUES (...)
        - INSERT INTO recipe_countries (...) VALUES (...)
    """
    # Get JSON data from the request body
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON data"}), 400

    # Extract recipe details
    recipe_name = data.get('name')
    description = data.get('description')
    instructions = data.get('instructions')
    preparation_time = data.get('preparation_time')
    cooking_time = data.get('cooking_time')
    servings = data.get('servings')
    image_url = data.get('image_url')
    dietary_preference = data.get('dietary_preference')
    ingredients_data = data.get('ingredients', []) # List of ingredient objects
    country_ids = data.get('country_ids', []) # List of country IDs

    # Basic validation
    if not recipe_name or not instructions or not dietary_preference:
        return jsonify({"error": "Recipe name, instructions, and dietary preference are required"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor()
    try:
        # Start a transaction for atomicity (either both recipe and ingredients are added, or none)
        conn.start_transaction()

        # Insert new recipe into the 'recipes' table
        cursor.execute(
            "INSERT INTO recipes (name, description, instructions, preparation_time, cooking_time, servings, image_url, dietary_preference) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
            (recipe_name, description, instructions, preparation_time, cooking_time, servings, image_url, dietary_preference)
        )
        recipe_id = cursor.lastrowid # Get the ID of the newly inserted recipe

        # Insert ingredients into the 'ingredients' table
        for ingredient in ingredients_data:
            name = ingredient.get('name')
            quantity = ingredient.get('quantity')
            unit = ingredient.get('unit')
            if name: # Only insert if ingredient name is not empty
                cursor.execute(
                    "INSERT INTO ingredients (recipe_id, name, quantity, unit) VALUES (%s, %s, %s, %s)",
                    (recipe_id, name, quantity, unit)
                )
        
        # Insert country associations into recipe_countries table
        for country_id in country_ids:
            cursor.execute(
                "INSERT INTO recipe_countries (recipe_id, country_id) VALUES (%s, %s)",
                (recipe_id, country_id)
            )

        conn.commit() # Commit the transaction if all inserts were successful
        return jsonify({"message": "Recipe added successfully", "recipe_id": recipe_id}), 201
    except mysql.connector.Error as err:
        conn.rollback() # Rollback the transaction if any error occurs
        # Improved error message for query failures
        print(f"ERROR: MySQL query failed when adding a new recipe. Details: {err}")
        return jsonify({"error": "Failed to add recipe"}), 500
    finally:
        cursor.close()
        conn.close()

# New API endpoint to fetch all countries for dropdowns
@app.route('/api/countries', methods=['GET'])
def get_countries():
    """
    API endpoint to fetch all countries from the database.
    Returns a JSON array of country objects.
    """
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id, name FROM countries ORDER BY name")
        countries = cursor.fetchall()
        return jsonify(countries), 200
    except mysql.connector.Error as err:
        print(f"ERROR: MySQL query failed when fetching countries. Details: {err}")
        return jsonify({"error": "Failed to fetch countries"}), 500
    finally:
        cursor.close()
        conn.close()


# --- Main execution block ---
if __name__ == '__main__':
    # Run the Flask application in debug mode.
    # This automatically reloads the server on code changes and provides detailed error messages.
    # For production, set debug=False.
    app.run(debug=True, port=5000) # You can change the port if 5000 is in use
