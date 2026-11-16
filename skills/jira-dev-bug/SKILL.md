---
name: jira-dev-bug
description: Fix a Jira Bug in one commit, without subtasks. Finds the root cause, weighs the possible fixes and argues for one (the simplest that matches how the codebase already solves the same problem), gets it approved, then fixes it test-first when a test can reproduce the bug. Never pushes, never opens or merges a merge request. Use when the user runs /jira-dev-bug <BUG-KEY>.
disable-model-invocation: true
---

# Fix a Bug, test-first, in one commit

Input: `$ARGUMENTS` = a Bug key (e.g. `PROJ-123`).

Output: one local commit on the bug branch that fixes the root cause, with a regression test when one is possible. **Never** `git push`, never create, approve or merge a merge request: the user does that.

Settings: read `.ai-toolbox.yaml` at the repo root if it exists, else `~/.config/ai-toolbox/config.yaml` (format: `config.example.yaml` in the ai-toolbox repo). Keys used: `jira.cloudId`, `git.bugBranch`, `vault.path` (optional). A required key missing → stop and say which one.

Jira: Atlassian MCP, `cloudId` = `jira.cloudId`. Resolve transitions by name, never by a remembered id.

`<main>` = the remote default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, without `origin/`).

## Steps

1. **Load the bug.** Read it (`summary,description,status,issuetype,issuelinks`). If it is a Story, stop and point to `/jira-plan-story` and `/jira-dev-story`. Keep the steps to reproduce, the expected and actual behaviour, and any definition of done: they are the target.
2. **Prepare the branch.**
   - `git status --short`: if the tree has changes, stop and ask what to do with them. Never stash, reset or commit someone else's changes.
   - On `<main>`: `git fetch origin <main>`, then `git switch -c <branch> origin/<main>`, where `<branch>` is `git.bugBranch` with `{KEY}` replaced by the Bug key.
   - On another branch: say which one and continue on it only if it belongs to this bug.
   - Move the bug to `In Progress` and assign it to the user (their `accountId` from `atlassianUserInfo`), unless someone else is already assigned: then ask before reassigning.
3. **Find the root cause.** If `vault.path` is set, check `<vault.path>/Home.md` for prior knowledge. Load the skills `AGENTS.md` lists for the area, then trace the symptom from the bug's steps to the line that causes it. Every link of the chain is a `path:line` read this session. Stop at the cause, not at the first place the symptom shows. If the code does not explain the symptom, stop and ask: do not fix a guess.
4. **Choose the fix, with arguments.** Before writing any code:
   1. **Look for precedents.** Search how the codebase already handles the same situation: the same component or event elsewhere, a sibling app, `git log -S '<symbol>'` and `git log --grep` for a past fix of the same kind. A precedent is a `path:line` or a commit.
   2. **List the candidate fixes**, two or three, including "fix it where the symptom shows" when it differs from the root cause.
   3. **Pick one** with these criteria, in this order:
      - it removes the root cause, not the symptom;
      - it follows the precedent: same fix, same pattern, same layer as the codebase already uses;
      - it is the smallest change that does it: removing code beats adding code, an existing helper beats a new one;
      - it does not change behaviour that the bug does not describe.
   4. **Gate.** Load the `asking-the-user` skill and post, in this order:
      - the root cause in one or two sentences, with its `path:line`;
      - the chosen fix and why, citing the precedent;
      - each rejected option with the reason in one line;
      - the regression test titles in business language, or why no test can reproduce the bug and what proof replaces it (see step 5);
      - what cannot be verified before merge (e2e, production-only behaviour).

      Wait for approval or corrections. Their answer is the target behaviour. A fix that needs an architecture decision (new abstraction, contract change, new dependency, data migration) is never decided alone: it is part of this question.
5. **TDD red → green.** Load the test skills `AGENTS.md` lists for the area.
   - Write the regression test first, run it, and see it fail **for the bug's reason**: the failure message must show the symptom of the ticket, not a setup error.
   - Write the approved fix, run the test, see it pass.
   - When no test can reproduce the bug (e2e that only runs on master, pure CSS, configuration, third-party behaviour), say so at the gate, not afterwards, and replace the test with the strongest proof available: an existing test that covers the path, typecheck, a manual reproduction from the ticket's steps. Never write that the fix was test-driven when it was not.
6. **Verify.** Run the focused tests of the touched modules, and lint and typecheck or compile them (the commands `AGENTS.md` or the build files give). Quote the real output. A failure is fixed, never reported as done.
7. **Commit** following the repo's commit convention (`AGENTS.md`, a commit skill, or `git log` style), subject `[<BUG-KEY>] ...`. The body says the root cause and why this fix, in two or three lines. Stage only the fix and its test by path, never `git add -A`. If the pre-commit hook fails, fix the cause and commit again, never `--no-verify`.
8. **Finish.** Print:
   - the root cause, the fix, and the commit sha;
   - the tests run with their result;
   - what is left to verify after merge, with the steps (e.g. the ticket's reproduction steps in production, the e2e job to watch);
   - the decisions you took alone, with their reason.

   Leave the bug in `In Progress`: it is done when the fix is merged and verified, which is the user's call. Then invoke the `capture-learnings` skill for this bug.

## While fixing

- **Scope**: fix this bug, nothing else. No refactoring, renaming or cleanup around it. Another bug or a smell found on the way → propose a new ticket (title + one line) and create it only if the user agrees. Never fold it into this commit.
- **No workaround that hides the symptom**: no added retries, longer timeouts, swallowed errors, or a guard that skips the bad case, unless the root cause is outside the codebase. Then say so at the gate and name where the real fix belongs.
- **If the approved fix turns out wrong** while coding (the test stays red for another reason, the precedent does not apply), stop and go back to the gate with what you learned. Never switch to another option silently.
- **Comments and tests** follow the conventions in `AGENTS.md`.
- **Fix in the owning code.** When the bug shows in a shared helper or in another team's code, say who owns the code (CODEOWNERS) at the gate.
