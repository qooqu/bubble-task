# Bubble Task

A small task board: workers are columns, tasks are rows, and clicking a bubble assigns a task and steps its progress by 25%.

## Status: mid-rewrite to Rails 8
- The plan and PR roadmap are in `docs/rails-rewrite-plan.md`. It is the plan of record: read it before starting work, and update it when a PR changes what later PRs need.
- Build roadmap items with the `next-pr` skill, one PR at a time.
- The old Express/MongoDB API and React app remain on `main` until cutover. Read them with `git show main:<path>` when porting.

## Branching
- PR branches come off `rails-rewrite` (or off the previous PR's branch, if that PR isn't merged yet) and target `rails-rewrite`.
- Never target `main` before cutover. Netlify and Heroku may still auto-deploy the live app from it.

## Environment
- There is no Ruby on the host. Run everything through `docker compose exec web …`, and start the app with `docker compose up`.
- Exact commands get filled in here once PR 1 creates the app.

## Checks before opening a PR
Run each of these through `docker compose exec web`:
- `bin/rubocop`
- `bin/brakeman`
- `bin/rails test`
- `bin/rails test:system`

There is no type checker.

## Conventions
- Every record lookup goes through `Current.user.workers` or `Current.user.tasks`, never a bare `Worker.find` or `Task.find`.
- Board actions respond with `turbo_stream.replace "board"`.
- Tests use Minitest with fixtures (no RSpec). Keep system tests to browser interactions only.
- Login is by email. There are no usernames.
