---
name: jira-dev-story
description: Implement the subtasks of a Jira Story, one commit per subtask, in dependency order, with TDD. Never pushes, never opens or merges a merge request. Ends when every subtask is committed, then captures learnings. Use when the user runs /jira-dev-story <STORY-KEY or SUBTASK-KEY>.
disable-model-invocation: true
---

# Implement a Story, one commit per subtask

Input: `$ARGUMENTS` = a Story key (implement all its open subtasks) or a subtask key (implement that one only).

Output: one local commit per subtask on the Story branch. **Never** `git push`, never create, approve or merge a merge request: the user does that. When every subtask is committed, the work is done.

Settings: read `.ai-toolbox.yaml` at the repo root if it exists, else `~/.config/ai-toolbox/config.yaml` (format: `config.example.yaml` in the ai-toolbox repo). Keys used: `jira.cloudId`, `jira.readyStatus`, `git.storyBranch`. A required key missing → stop and say which one.

Jira: Atlassian MCP, `cloudId` = `jira.cloudId`. Resolve transitions by name.

`<main>` = the remote default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, without `origin/`).

## Steps

1. **Load the work.** Read the Story and its subtasks (`summary,description,status,issuelinks`). Keep subtasks not in a done category. Order them by their `Blocks` links (a subtask comes after every subtask that blocks it); break ties by key. If a subtask has no `## Implementation brief`, say so and suggest `/jira-plan-story` before going on.
2. **Prepare the branch.**
   - `git status --short`: if the tree has changes, stop and ask what to do with them. Never stash, reset or commit someone else's changes.
   - On `<main>`: `git fetch origin <main>`, then `git switch -c <branch> origin/<main>`, where `<branch>` is `git.storyBranch` with `{KEY}` replaced by the Story key.
   - On another branch: say which one and continue on it only if it belongs to this Story.
3. **Test-list gate, once, before any code.** Load the `asking-the-user` skill. Post, per subtask in order, the test titles you plan to write, one line each, in business language, no implementation. Wait for approval or corrections. Their answer is the target behaviour.
4. **For each subtask, in order:**
   1. Move it to `In Progress`.
   2. Re-read its brief and confirm it against the current code: the `path:line` and patterns it cites must still exist. A brief that contradicts the code → stop and ask.
   3. Load the skills `AGENTS.md` lists for the area, the testing ones above all.
   4. **TDD red → green** for each approved test title: write the failing test, run it and see it fail, write the minimal production code, run it and see it pass. No production code without a failing test that requires it.
   5. **Verify**: run the focused tests of the touched modules (the commands `AGENTS.md` or the build files give) and compile the touched modules. Quote the real output. A failure is fixed, never reported as done.
   6. **Commit** following the repo's commit convention (`AGENTS.md`, a commit skill, or `git log` style), subject prefixed with the **subtask** key (`[PROJ-1234] ...`). Stage only this subtask's files by path, never `git add -A`. If the pre-commit hook fails, fix the cause and create the commit again; never `--no-verify`.
   7. Move the subtask to `Done` once the commit exists, then re-read its status to confirm.
   8. Report one line: `KEY — commit sha — tests run`, then go to the next subtask.
5. **Finish.** Print a table `subtask | commit | tests`, and the list of decisions you took alone with their reason. Then invoke the `capture-learnings` skill for this Story.

## While implementing

- **Architecture or differentiating trade-off not settled by the brief** (new abstraction, contract shape, table vs column, event vs direct call, new dependency, two options with different observable results) → stop and ask with `asking-the-user` before coding that part. Never decide it and mention it afterwards.
- **Scope**: implement the brief, nothing more. Work discovered outside it → propose a new subtask (title + one line); create it under the Story in `jira.readyStatus` only if the user agrees. Never fold it into the current commit.
- **Comments and tests** follow the conventions in `AGENTS.md`.
- **Jira statuses**: a subtask goes `In Progress` when started and `Done` right after its commit. The Story's status is never touched.
- A subtask that cannot be finished (blocker, failing environment) → stop, leave it `In Progress`, say exactly what blocks, and do not start the subtasks that depend on it.
