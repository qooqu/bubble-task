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

## Code style: idiomatic, simple Rails
- Prefer Rails conventions over custom solutions. Use what Rails and the standard library already provide before writing new abstractions or adding gems.
- Keep it simple: write the most straightforward code that solves the problem. No speculative abstractions, configuration options or "future-proofing" the task didn't ask for.
- Follow "the Rails way":
  - RESTful controllers with only the standard actions. When something needs a custom action, make it a resource of its own instead (e.g. `Tasks::ProgressesController#update`, not `TasksController#click`).
  - Logic lives in models, with concerns when it's shared.
  - Use ActiveRecord validations, and scopes for reusable queries.
  - Use callbacks sparingly.
- Don't introduce service objects, form objects, interactors or other patterns unless the codebase already uses them for that kind of problem.
- Write idiomatic Ruby: Enumerable methods over manual loops, guard clauses over nested conditionals, small methods with clear names.
- Match the patterns already in this codebase over general best practices from elsewhere.
- New gems need justification. Ask before adding one, unless `docs/rails-rewrite-plan.md` already names it (those are pre-approved).

## Conventions
- Every record lookup goes through `Current.user.workers` or `Current.user.tasks`, never a bare `Worker.find` or `Task.find`.
- Board actions respond with `turbo_stream.replace "board"`.
- Tests use Minitest with fixtures (no RSpec). Test behavior, not implementation, and keep system tests to browser interactions only.
- Login is by email. There are no usernames.
