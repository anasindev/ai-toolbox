---
name: capture-learnings
description: Write the functional and technical knowledge gained during a piece of work into the user's Obsidian vault, formatted for a future Claude to retrieve and trust. Use at the end of /jira-dev-story or /jira-dev-bug, after a merge, after an investigation, or when the user says "capture learnings", "save what we learned", "write this to Obsidian".
---

# Capture learnings for a future Claude

Vault: `vault.path`, read from `.ai-toolbox.yaml` at the repo root if it exists, else `~/.config/ai-toolbox/config.yaml` (format: `config.example.yaml` in the ai-toolbox repo). No `vault.path` → stop and say so. Below, `<vault>` is that path. Index: `Home.md` lists the folders; each folder has an `index.md` that lists its notes. Reader: a future Claude session that knows nothing about this one. It reads `Home.md`, then one folder's `index.md`, opens one or two notes, and acts on them. Write for that reader: facts it can rely on and find, not a story.

Input: `$ARGUMENTS` = optional Story / ticket key or topic. Default: the work done in this session.

## Steps

1. **Collect candidates** from the session: the commits (`git log origin/HEAD..HEAD`), the Jira ticket and subtasks, decisions the user validated, pitfalls hit, commands that worked.
2. **Filter.** Keep an item only if all hold:
   - a future task in this area would go faster or avoid a mistake knowing it;
   - it is not readable directly from the code, `AGENTS.md` or a repo skill;
   - it is general, not the narrative of this session.
   Trivial work (rename, config bump, small fix) usually yields nothing: then write nothing and say so.
3. **Verify every item** against the current code or the real source (Jira, monitoring, analytics) before writing. Cite `path:line`. Never write from session memory alone. Unverifiable → drop it, or write it under `## Open questions`.
4. **Find the home.** Read `Home.md` and the relevant folders' `index.md`, and search the vault (`grep -ril <keyword> <vault> --include=*.md`). Prefer updating an existing note over creating one. If an existing note is contradicted by the code, correct it in place and bump `last_verified`.
5. **Write** (§ NOTE FORMAT). Folders:
   - `Features/` — one note per product feature or Story area (e.g. unified keyword search): what it does, how it is built.
   - `Concepts/` — a domain concept or mechanism reused across features.
   - `How-to/` — a procedure that worked (commands, queries, steps).
   - `Investigations/YYYY-MM-DD <title>.md` — a dated finding from data or prod.
   - A new folder only when a note fits none of these; it gets its own `index.md` (step 6).
6. **Index.** Add each new note to its folder's `index.md` as `- [[Note title]] — <summary>` (Investigations: newest first). When a note changes its `summary`, update its line too. Never reorder or rewrite other lines.
   New folder: create `<Folder>/index.md` with `# <Folder>`, one line saying what belongs there, then the note lines; and add `- [[<Folder>/index|<Folder>]] — <what belongs there>` to `Home.md`. `Home.md` lists folders only, never notes.
7. **Report** to the user: notes created or updated, one line each, and items deliberately dropped.

## Note format

```markdown
---
tags: [<area>, <technology>]
summary: <one factual line: what this note lets a reader do or know>
sources: [<STORY-KEY>, <MR or commit>, ...]
last_verified: YYYY-MM-DD
---
# <Durable noun title>

## Functional
- <business rule or invariant, with the domain's own words>

## Technical
- <fact> — `path/to/file.ext:42` — <consequence if ignored>

## Pitfalls
- <trap> — <how to avoid it>

## Open questions
- <unverified point>

Related: [[Other note]], [[Other note]]
```

Drop empty sections. Rules for each bullet:
- One fact, one line, the project's real names (classes, flags, events, endpoints), never a paraphrase.
- Facts and rules, in the present tense. No "we", no "in this session", no chronology.
- A `path:line`, flag name, event name, query or command whenever one exists, so the reader can re-check it.
- Say why it matters when that is not obvious: what breaks, what it costs.
- English.

## Red flags

- A note with no `path:line` or source at all.
- A bullet that retells what was done instead of what is true.
- A new note that duplicates a topic already in a folder `index.md`.
- A note missing from its folder `index.md`, or a folder with no `index.md`.
- Writing something because the session was long, not because it is reusable.
