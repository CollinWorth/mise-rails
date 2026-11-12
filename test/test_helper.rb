ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

class ActiveSupport::TestCase
  def create_user(name: "Cook", email: "#{name.downcase}@example.com")
    User.create!(name:, email_address: email, password: "secret123")
  end

  def create_recipe(user, name: "Soup", public: true, ingredients: [])
    user.recipes.create!(name:, public:, ingredients_attributes: ingredients.each_with_index.map { |attrs, position| attrs.merge(position:) })
  end

  def attach_image(recipe)
    recipe.image.attach(io: file_fixture("dish.jpg").open, filename: "dish.jpg", content_type: "image/jpeg")
    recipe
  end
end

class ActionDispatch::IntegrationTest
  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "secret123" }
  end
end
