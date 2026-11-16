---
name: jira-plan-story
description: Split a Jira Story into implementable subtasks. Reads the Story, analyses the code, proposes a dependency-ordered split, asks every decision that is not Claude's to take, then creates the subtasks with an implementation brief each. Never writes code. Use when the user runs /jira-plan-story <STORY-KEY> or asks to plan or split a Story into subtasks.
disable-model-invocation: true
---

# Plan a Story into subtasks

Input: `$ARGUMENTS` = a Story key (e.g. `PROJ-123`). The Story and its Epic are owned by the product manager: read them, never edit them, never comment on them.

Output: subtasks created under the Story, each in the `jira.readyStatus` status, each carrying a brief precise enough for `/jira-dev-story` to implement without inventing anything. Planning stops there: no code, no branch, no commit.

Settings: read `.ai-toolbox.yaml` at the repo root if it exists, else `~/.config/ai-toolbox/config.yaml` (format: `config.example.yaml` in the ai-toolbox repo). Keys used: `jira.cloudId`, `jira.readyStatus`, `vault.path` (optional). A required key missing → stop and say which one.

Jira: Atlassian MCP, `cloudId` = `jira.cloudId`. Resolve transitions by name, never by a remembered id.

`<main>` = the remote default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, without `origin/`).

## Steps

1. **Read the Story** (`getJiraIssue`, fields `summary,description,status,parent,subtasks`) and its parent Epic for context. List existing subtasks so nothing is duplicated. If the input is not a Story, stop and say what it is.
2. **Sync with `<main>`** without touching the working tree: `git fetch origin <main>`, and read code at `origin/<main>` (`git show origin/<main>:<path>`) when the current branch is behind.
3. **Analyse.** Load the domain skills listed in `AGENTS.md` for the areas touched. If `vault.path` is set, check `<vault.path>/Home.md` first for prior knowledge, then delegate wide code exploration to an `Explore` subagent that returns `path:line` facts, not file dumps. Every structuring fact must trace to a source read this session; mark anything unverified as an assumption.
4. **Draft the split** with the rules in § SPLITTING RULES, and write the decision register (§ DECISION CHECKPOINT) as you go.
5. **Decision checkpoint, blocking.** Load the `asking-the-user` skill, then post:
   - the proposed split, at most 10 lines, one per subtask: `short title — what it delivers — depends on X`, then ask: merge, split, or OK?
   - the register questions, batches of at most 4 (`AskUserQuestion`), most structuring first.
   No subtask is created before the answers are back.
6. **Create the subtasks** (§ SUBTASK FORMAT), then add the dependency links, then move each to `jira.readyStatus` and re-read its status to confirm it. A subtask left in the project's initial status may be invisible on the board.
7. **Recap**: one line per subtask (`KEY — title — depends on`), in implementation order, plus every register line marked `DECIDED ALONE`, so the user can object. Suggest `/jira-dev-story <STORY-KEY>` as the next step.

## Splitting rules

Apply in order. The split is a proposal validated at the checkpoint, not a decision.

- **R1 Vertical slice.** One small feature = one subtask, back and front together, when they are coupled by a new contract. Splitting them ships a contract with optional fields that later become required: two changes and debt. Exception: a large backend part (new table, migration, non-trivial logic) or an already stable contract → backend subtask first, front subtask depends on it, contract required from the start.
- **R2 Merge small changes.** Several small changes on the same area or flow → one subtask. A change worth ~30 lines with no logic of its own joins the closest coherent subtask. This threshold only merges upward; never split a coherent subtask because it is large.
- **R3 One owner per hot file.** Two subtasks must not both edit a hot file heavily (router, app config, OpenAPI contract, central mapper, feature-flag definitions, registration list). Give it to one subtask; the others depend on it.
- **R4 Foundations first.** Contracts, schemas, migrations, shared ports and DTOs are roots; consumers depend on them and start from merged foundations. A cycle (A needs B, B needs A) means a bad split: merge them.
- **R5 Check.** Re-read the split against R1–R4 before the checkpoint. Each subtask must be testable alone and reviewable as one commit.

## Decision checkpoint

Keep a register in the conversation, one line per decision met during analysis:
`# | decision | DECIDED ALONE or TO ASK | proof (path:line of the copied pattern) or user answer`

**The default is TO ASK.** Deciding alone is allowed only when all three hold:
1. no observable effect (screen, data, message, delay, public API surface, failure behaviour);
2. reversible inside the subtask, without migration or contract change;
3. an existing pattern in the repo is copied, cited as `path:line`.

Always asked, never decided alone: scope (especially what is out), the split and its order, any new or changed contract (endpoint, field, event, table, column, enum), feature flag yes/no and who turns it on, data migration, visible changes, deletion or deprecation, behaviour when data is missing / duplicated / a call fails, a new dependency.

A decision discovered while writing subtasks is added to the register; if it is TO ASK, ask it before writing that subtask.

## Subtask format

Create with `createJiraIssue`: `projectKey` = the Story's project, `issueTypeName` = the project's subtask type (read it from an existing subtask or `getJiraProjectIssueTypesMetadata`, it may be localized), `parent` = the Story key, `contentFormat: markdown`. Do not assign. Everything in **English**.

- **Summary**: imperative, under 70 characters, names what changes.
- **Description**:

```
<2-3 sentences: what this delivers, from the user's or system's point of view>

## Done when
- <observable acceptance criterion>

## Implementation brief
- Files: `path:line` entry points to change
- Pattern to copy: `path:line` of the closest existing implementation
- Contract: exact fields / endpoint / event, if any
- Tests to write: one line per business case
- Decisions: each relevant register line, tagged DECIDED WITH USER or DECIDED ALONE
- Pitfalls: anything non-obvious found during analysis
- Depends on: <subtask keys or "none">
```

Never ask the implementer to explain reasoning in code comments; the brief carries the context.

**Dependency links**: for each edge "B needs A merged", call `createIssueLink` with `type: "Blocks"`, `inwardIssue: A`, `outwardIssue: B`. These links are what `/jira-dev-story` reads to order the work.

## Red flags

- The first question to the user is "OK to create the subtasks?": the checkpoint did not happen.
- Fewer than 3 register lines on a Story split into more than 3 subtasks: decisions were not looked for.
- A `DECIDED ALONE` line without a `path:line`.
- A brief containing a choice (table name, default value, error behaviour) absent from the register.
- Any write to the Story or the Epic.
