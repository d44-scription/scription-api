# COMP3000-scription-web

Web application component of the Scription application

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

As the output states, a number of these can be autocorrected by adding `-a` to the end of the command.
