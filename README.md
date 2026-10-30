# Bubble Task

A small task board: workers are columns, tasks are rows, and clicking a bubble assigns a task and steps its progress.

Rails 8.1 with Hotwire and SQLite, deployed with Kamal. The rewrite plan is in [docs/rails-rewrite-plan.md](docs/rails-rewrite-plan.md).

## Development

You only need Docker; Ruby runs in the container.

```sh
docker compose up -d                        # install gems, prepare the db, start on http://localhost:3000
docker compose exec web bin/rails console   # any other command: docker compose exec web …
docker compose attach web                   # reach a `debugger` breakpoint (detach: Ctrl-P Ctrl-Q)
```

## Tests and checks

```sh
docker compose exec web bin/ci                 # everything GitHub Actions checks (steps in config/ci.rb)
docker compose exec web bin/rails test         # just the unit tests
docker compose exec web bin/rails test:system  # just the system tests
```

## Production

Kamal runs from its Docker image, so these work from the host. The aliases are in [config/deploy.yml](config/deploy.yml).

```sh
GITHUB_TOKEN=$(gh auth token) bin/kamal deploy  # deploy main once CI has passed on it
bin/kamal console                               # Rails console
bin/kamal logs                                  # follow the app's logs
bin/kamal shell                                 # bash in the app container
bin/kamal dbc                                   # sqlite3 on the production database
```
