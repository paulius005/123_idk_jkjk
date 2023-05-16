# Setup

1. Ensure you have `Node 19`, `Ruby 3.2.2`, & `pnpm` installed on your machine.
2. Create and fill in `.env` using `.env.example` as an example.
3. Setup your postgres database. If you prefer just command line you can use the command below. [DBngin](https://dbngin.com/) is also a quick and easy way to get a local db started.

```
Brew install postgresql
```

5. Setup your client: `pnpm client:setup`
6. Setup your API: `pnpm api:setup`
7. Start your API: `pnpm api:start`
8. Start your client (new terminal tab): `pnpm client:start`

# Tests

Run `pnpm api:test` to run the rails app tests. The client does not have any tests currently.

# Script

1. Create and fill in `.env` using `.env.example` as an example in the `/scripts` directory.
2. Run `bundle install`
3. Run the script in the following format: `ruby pdf_to_pages_embeddings.rb product_engineering_challenge.pdf`
4. Copy the resulting csv files `product_engineering_challenge.pdf.embeddings.csv` & `product_engineering_challenge.pdf.pages.csv` to the `/api/app/data/` directory. You will notice this already has the generated files, so the application can work.

# Deployment

Deployment is done with Railway. A push with changes to the `main` branch will trigger a new deploy.

To deploy a new frontend run `pnpm run build:prod`, commit, and push to `main`.

Railway Ruby docs can be found [here](https://nixpacks.com/docs/providers/ruby)

The root directory for the application for Railway is `/api`

The build command is `bundle exec rails db:migrate`
