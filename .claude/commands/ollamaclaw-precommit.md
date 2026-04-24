# Ollamaclaw Pre-Commit Review

Perform a pre-commit safety review for the current repo.

Scope/details: `$ARGUMENTS`

Instructions:
1. Use `scope-lock` to define intended commit scope.
2. Use `git-guardian` to inspect branch state, changed files, untracked files, ignored/local files, and do-not-commit risks.
3. Use `settings-warden` if `.claude/settings*` changed.
4. Use `commit-captain` to propose staging commands and commit messages.

Constraints:
- Do not commit.
- Do not push.
- Do not stage files unless explicitly asked.
