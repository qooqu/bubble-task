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

## Keeping it up to date

The server is a TierHive NAT VPS running Ubuntu 26.04. Ubuntu's unattended-upgrades installs security updates daily and reboots at 04:00 UTC when one needs it. The reboot setting is in `/etc/apt/apt.conf.d/52unattended-upgrades-reboot`, set up by hand because Kamal doesn't manage the host. The app containers restart on their own after a reboot.

Everything else is by hand, about once a month:

```sh
ssh -p 3768 root@207.241.173.35 'apt update && apt full-upgrade -y'  # Docker and other non-security packages
ssh -p 3768 root@207.241.173.35 'cat /var/run/reboot-required'      # if it exists, reboot
docker compose exec web bundle update                                # then bin/ci, PR, merge and deploy
```

- Bump Ruby when a patch release is out, in `.ruby-version`, `Dockerfile` and `Dockerfile.dev`. That also brings in a fresh base image.
- After updating Kamal, run `bin/kamal proxy reboot` to pick up a newer kamal-proxy.
