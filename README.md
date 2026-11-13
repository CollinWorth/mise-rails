# Mise

Recipes, meal planning and groceries: save recipes (or import them from a web page), drop them on days of the week,
and turn the week into one grocery list that leaves out what you always have in your pantry.

Rails 8.1 with Hotwire (Turbo and Stimulus through importmap), Phlex views built from the
[Ruby UI](https://rubyui.com) component library, Tailwind 4, Active Record and Active Storage.
SQLite for development and tests, Postgres and an S3-compatible bucket in production (Railway).

## Running it (no local Ruby needed)

    docker build -t mise-rails-dev -f Dockerfile.dev .                   # once (includes Chromium for the browser tests)
    bin/d bin/rails db:prepare db:seed                                   # sample cooks and recipes (development only)
    bin/d bin/rails tailwindcss:build                                    # rerun after adding views or classes
    docker run --rm -u $(id -u):$(id -g) -e HOME=/tmp -p 3300:3000 -v mise-bundle:/usr/local/bundle -v "$PWD":/app mise-rails-dev bin/rails s -b 0.0.0.0

`bin/d <command>` runs any command inside the dev container. Sample login: `cook@example.com` / `secret123`.

## Tests and checks

    bin/d bin/rails test                  # models, integration, and the structure guards in test/components
    bin/d bin/rails test:system           # browser tests in phone-sized headless Chromium (some switch to desktop width)
    COVERAGE=1 bin/d bin/rails test       # also writes coverage/ (run test:system with COVERAGE=1 too; results merge)
    bin/d bin/rubocop && bin/d bin/brakeman -q --no-pager && bin/d bin/bundler-audit && bin/d bin/importmap audit

CI (`.github/workflows/ci.yml`) runs the same. Run `rails test` and `rails test:system` as separate commands.

## How the front end is built

- **Views compose components; they contain no raw tags or colors.** Pages in `app/views` use the RubyUI components
  (`Button`, `Card`, `Badge`, `Heading`, `Text`, ...) and the small layout kit in `app/components` (`Stack`, `Row`, `Grid`,
  `Narrow`, `Sheet`, `Menu`, `Tag`, `Avatar`, ...). `test/components` fails if a view uses a raw tag or any file uses a
  fixed color.
- **Themes.** Every color is a theme token (`bg-primary`, `text-muted-foreground`, `bg-brand-2/10`, ...). A theme is one block
  of eight hex colors in `app/assets/tailwind/application.css` (`[data-palette="sunrise"]`) plus a name in
  `app/models/palette.rb`; everything else is derived. People pick *Match my device / Light / Dark* and a light and a dark
  theme in their profile. To add a theme: paste a block, add a line to `Palette::LIGHT` or `Palette::DARK`; a test checks
  the colors stay readable.
- **Sheets.** Pickers and editors open in a full-screen sheet on phones and a centered dialog on desktops
  (`Components::Sheet`, loaded into the layout's `modal` Turbo Frame).
- **Forms respond with a redirect or an error status.** Turbo refuses a 200 page in answer to a form post: re-render with
  `status: :unprocessable_content`, or redirect with `status: :see_other`.
- **Stimulus controllers** (`app/javascript/controllers`) are small and named for what they do: `reorder` (drag by a grip,
  via SortableJS), `nested_form` (ingredient rows), `steps` (instruction steps), `checklist` (ticks while cooking), `menu`,
  `sheet`, `appearance`, `landing_palette`, ...

## Where things are

- `app/models` – domain logic as plain objects and concerns: `Recipe`, `GroceryList`, `ShoppingTrip`, `IngredientTotals`,
  `Units` (merging 2 cups and 1 tbsp), `Quantity`, `RecipeImport` (URL or pasted text), `RemoteFetch` (SSRF-safe downloads),
  `MongoImport`, `Palette`.
- `app/controllers` – resourceful controllers only.
- `app/components/landing` – the front page for visitors.
- `config/grocery_categories.yml` – aisle order and keywords for sorting the grocery list.
- `lib/tasks` – `import:mongo`, `images:variants`, `icons:generate` (below).

## Tasks

    bin/d bin/rails icons:generate        # redraws the logo and every icon size into public/ (bump ICON_VERSION in the layout)
    bin/d bin/rails images:variants       # prepares the WebP versions of every recipe photo (new uploads prepare themselves)
    bin/rails import:mongo DIR=path/to/cookindb [UPLOADS=path] [CONFIRM=wipe]
                                          # replaces everything with a mongodump of the old Mise; reads files only

## Deploying (Railway)

The repo deploys from its `Dockerfile` (`railway.toml` sets the health check at `/up`). Environment variables on the web service:

| Variable | Value |
|---|---|
| `DATABASE_URL` | reference to the Postgres service |
| `RAILS_MASTER_KEY` | the contents of `config/master.key` |
| `BUCKET`, `BUCKET_ENDPOINT`, `BUCKET_REGION`, `BUCKET_ACCESS_KEY_ID`, `BUCKET_SECRET_ACCESS_KEY` | the photo bucket (without `BUCKET`, photos go to the container's disk and are lost on deploy) |

Migrations run when the server starts. Photos are served through the app as WebP, cached by the browser for good.
