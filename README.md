# Mise (Rails)

Bare-bones Rails 8 rewrite of Mise: recipes, discovery, meal planning and a grocery list.
Backend is Rails (Active Record, Active Storage, built-in authentication). Front end is
server-rendered Hotwire with Phlex views and the [Ruby UI](https://rubyui.com) component library.
Views contain no raw HTML or CSS: they use Ruby UI components plus the layout kit in `app/components`
(`Stack`, `Row`, `Grid`, `Container`, `Field`, `ActionForm`, ...).

## Running (no local Ruby needed)

    docker build -t mise-rails-dev -f Dockerfile.dev .                   # once (includes Chromium for system tests)
    bin/d bin/rails db:prepare
    bin/d bin/rails tailwindcss:build                                    # rerun after adding views/classes
    bin/d bin/rails test
    bin/d bin/rails test:system                                          # browser tests, phone-sized Chromium
    docker run --rm -u $(id -u):$(id -g) -e HOME=/tmp -p 3300:3000 -v mise-bundle:/usr/local/bundle -v "$PWD":/app mise-rails-dev bin/rails s -b 0.0.0.0

`bin/d <cmd>` runs any command in the dev container. The database is local SQLite (`storage/`) until a real one is set up.

## Layout

- `app/models` – domain logic: `Recipe` (copies, ratings, visibility), `GroceryList#add_meals`, `Quantity`, `RecipeImport`
- `app/controllers` – resourceful controllers only (likes, ratings, copies, cook mode, grocery items are their own resources)
- `app/views` – one Phlex view per page; `app/components` – shared components
- `config/grocery_categories.yml` – aisle order and keywords for sorting the grocery list
