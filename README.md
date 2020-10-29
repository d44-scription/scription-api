# COMP3000-scription-api

API for the Scription application

## Running locally

The application is Dockerised, so should be fairly standard. Clone the repo and, when in the apps directory, run:

```bash
$ docker-compose build
  > ...
  > Successfully tagged scription-web_web:latest
```

to build all containers. Then you'll need to host the containers locally using:

```bash
$ docker-compose up db
  > ...
  > Creating scription-web_db_1 ... done

$ docker-compose up web
  > Creating scription-web_web_1 ... done
  > Attaching to scription-web_web_1
  > web_1  | => Booting Puma
  > web_1  | => Rails 6.0.3.4 application starting in development
  > web_1  | => Run `rails server --help` for more startup options
  > web_1  | Puma starting in single mode...
  > web_1  | * Version 4.3.6 (ruby 2.7.1-p83), codename: Mysterious Traveller
  > web_1  | * Min threads: 5, max threads: 5
  > web_1  | * Environment: development
  > web_1  | * Listening on tcp://0.0.0.0:3000
  > web_1  | Use Ctrl-C to stop
```

The API is now hosted at `localhost:3000`, so point other applications to this.

## Linting Code

This app uses [Rubocop](https://github.com/rubocop-hq/rubocop) for linting. To check for offences use:

```bash
$ docker-compose run --rm web bundle exec rubocop
  > X files inspected, Y offenses detected, Z offenses auto-correctable
```

As the output states, a number of these can be autocorrected by adding `-A` to the end of the command.

## Running Tests

This app uses RSpec as it's testing framework. To run tests use:

```bash
$ docker-compose run --rm -e RAILS_ENV=test web bundle exec rspec
  > Finished in X seconds (files took Y seconds to load)
  > X examples, Y failures, Z pending
```

This can also accept a path or can be filtered to run:

1. only specs that failed in previous runs
2. all specs found in a path
3. a specific example in a given suite

```bash
$ docker-compose run --rm web -e RAILS_ENV=test bundle exec rspec --only-failures
  > Finished in X seconds (files took Y seconds to load)
  > X examples, Y failures, Z pending

$ docker-compose run --rm web -e RAILS_ENV=test bundle exec rspec spec/requests
  > Finished in X seconds (files took Y seconds to load)
  > X examples, Y failures, Z pending

$ docker-compose run --rm web -e RAILS_ENV=test bundle exec rspec spec/requests/notebooks_spec.rb:19
  > Finished in X seconds (files took Y seconds to load)
  > X examples, Y failures, Z pending
```

## Adding a new Notable type

The notable model uses Single-Table Inheritance. Therefore no database migrations or changes are needed to add a new type.

1. Create a new model for the Notable type (ie `app/models/item.rb`). This must inherit from the `Notable` model. Any custom behaviour for this model should go here
2. Add the name of your new model to the `Notable::TYPES` constant (at time of writing this is found at `app/models/notable.rb:12`)
3. Add a `has_many :type` relationship to notebooks
4. Here you can add seed data to `db/seeds.rb` for your new model
5. Create a new controller & routes for your type. The new controller needs just an `index` action so that lists of certain notable types can be retrieved
6. Create views for the new type. An `index` view must be defined, but you will also need a `_type.json.jbuilder` partial where `type` is, well, your new `type`. This will allow the `notables#show` action to render your type with any custom behaviour needed

### The **bare minimum** tests required

1. Add a new trait to the `notable` factory that accepts your new type
2. Add a request spec file to test your index action. Confirm that notables of any other type are **not** included
3. Add to the `notable` request spec. You'll need to create a new object of your type and follow the pattern used for the exiting `item` and `character` objects to confirm it is retrieved in the overall notables index and not retrieved when viewing a different object. Add to the `post#CREATE` action to confirm that new notables of your type are created and assigned to the correct type. You can do this by checking the contents of `notebook.type` before and after the request, as has been demonstrated.
4. Add to the `notable` model spec to confirm that it accepts your new type

Additional specs should be added to cover any additional behaviour your type has
