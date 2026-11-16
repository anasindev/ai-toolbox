# ai-toolbox

My personal skills and agents for Claude Code. Nothing in here is tied to an employer: anything account- or project-specific lives in a config file outside the repo.

## Install

```bash
./install.sh                                         # symlinks skills/* and agents/* into ~/.claude
mkdir -p ~/.config/ai-toolbox
cp config.example.yaml ~/.config/ai-toolbox/config.yaml   # then fill it in
```

A repo can override the global config with its own `.ai-toolbox.yaml` at its root.

## Skills

- **asking-the-user.** Form of every question asked to the user: fact, question, options, recommendation, 150 words max.
- **writing-for-humans.** Rules for any document a human reads: conclusion first, length per document type, no AI writing tics.
- **capture-learnings.** Writes reusable knowledge from a piece of work into an Obsidian vault (`vault.path`).
- **clean-commit.** `/clean-commit`: removes debug leftovers, documents a surprising solution if needed, commits.
- **jira-plan-story.** `/jira-plan-story KEY`: splits a Story into ordered subtasks with an implementation brief each.
- **jira-dev-story.** `/jira-dev-story KEY`: implements those subtasks, TDD, one commit each.
- **jira-dev-bug.** `/jira-dev-bug KEY`: root cause, argued fix, regression test, one commit.
- **jira-create-bug.** Writes a Jira Bug a PM or QA can reproduce without reading code.

The `jira-*` skills expect the Atlassian MCP to be connected. Repo-specific things (test commands, commit convention, domain skills) are read from the repo's `AGENTS.md`.

## Agents

- **verification-agent.** Read-only adversarial verifier: tries to break an implementation and returns PASS, FAIL or PARTIAL with real command output.

## Third-party tools I use

Not vendored here, install them from their source. See [THIRD_PARTY.md](THIRD_PARTY.md).
