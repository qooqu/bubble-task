---
name: next-pr
description: ALWAYS use this whenever starting work on a new PR or the next item in a plan's PR roadmap — e.g. "start the next PR", "move on to PR 2", "let's do the next one", "go ahead with the next step" — even if /next-pr isn't typed. Builds one PR, opens it, self-reviews with /code-review --fix, pushes fixes, then stops for human review.
---

# Next PR

Build exactly ONE PR from the current plan's PR roadmap, then stop and hand off for human review.

If the user passed an argument (e.g. "PR 3"), build that one. Otherwise build the first roadmap item that isn't done.

## Steps

1. **Pick the PR.** Read the plan and find the PR to build. If it's unclear which one is next, or the plan is missing, ask instead of guessing.

2. **Branch.** Create a branch for it off the right base (the default branch, or the previous PR's branch if this PR depends on unmerged work). Name it after the PR's purpose.

3. **Implement.** Make the changes for this PR only. Stay inside its scope; note anything out of scope for a later PR rather than doing it now. Run the project's tests, linter and type checker and fix failures.

4. **Open the PR.** Commit, push, and open the PR with `gh pr create`. The description should summarize what changed and why, and reference the plan item.

5. **Self-review.** Run `/code-review --fix main...HEAD` (replace `main` with this PR's actual base branch).
   - Pass the range explicitly. After pushing, the branch has no commits ahead of its upstream, so a bare `/code-review` would find nothing to review.
   - The review runs in the background. Wait for its findings to arrive before doing anything else.

6. **Check the fixes.** Look over the edits the review applied. Revert any that are wrong or out of scope. Then check the whole PR diff against the "Code style" section of CLAUDE.md and fix any over-engineering or non-idiomatic code. Re-run tests, linter and type checker.

7. **Push the fixes.** Commit them as a separate commit (e.g. "Address self-review findings") and push, so the human reviewer can see what the review changed.

8. **Update the plan.** If anything in the PR or review changes later roadmap items, update the plan.

9. **Hand off and STOP.** Tell the user the PR is ready for human review:
   - the PR link
   - a 2–4 line summary of what it does
   - what the self-review found and fixed, and anything it flagged that you chose not to fix (with why)
   - anything the human reviewer should look at closely

   Do not start the next PR. Wait for the user's review feedback or approval.
