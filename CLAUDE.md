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
- The host has Ruby (via mise) and the bundled gems only for editor tooling such as Ruby LSP. Don't run the app, tests or `bin/rails` commands there. Ruby 4.0 and Rails 8.1 run in docker compose (`compose.yml`, `Dockerfile.dev`). `Dockerfile` is the production image, used only by Kamal.
- Start the app with `docker compose up -d` and open http://localhost:3000. The `web` service runs `bin/setup`, which installs gems into the `bundle` volume, prepares the database and starts the server.
- Run commands with `docker compose exec web …` (e.g. `bin/rails console`, `bin/rails db:migrate`, `bin/rails generate …`).
- After changing the Gemfile, run `docker compose restart web`. `bin/setup` re-runs `bundle install` on start.
- Edit credentials with `docker compose exec -e EDITOR=nano web bin/rails credentials:edit`.
- Deploy with `bin/kamal deploy`. It runs Kamal from its Docker image and needs `GITHUB_TOKEN` in the environment for the `pre-deploy` CI check. Images go through Kamal's local registry (`localhost:5555`) over SSH, so there's no hosted registry or registry password.
- For `debugger` breakpoints, run `docker compose attach web` (detach with Ctrl-P Ctrl-Q).
- Mail sent in development is caught, not delivered. Read it at http://localhost:3000/letter_opener.
- System tests run in the `chrome` service when `SELENIUM_HOST` is set (it is in compose). Without it, as in CI, they use local headless Chrome.

## Checks before opening a PR
Run `docker compose exec web bin/ci`. It runs the steps in `config/ci.rb`, which cover everything GitHub Actions checks: RuboCop, the gem and importmap audits, Brakeman, unit and system tests, plus seeds. Fix every failure before opening the PR.

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

## When reviewing code
- Flag over-engineering and non-idiomatic Rails (see Code style) as real issues, not nits.
- Ignore anything CI already enforces (RuboCop, Brakeman, formatting).

## Conventions
- Every record lookup goes through `Current.user.workers` or `Current.user.tasks`, never a bare `Worker.find` or `Task.find`.
- Board actions respond with `turbo_stream.replace "board"`.
- Tests use Minitest with fixtures (no RSpec). Test behavior, not implementation, and keep system tests to browser interactions only.
- Login is by email. There are no usernames.
