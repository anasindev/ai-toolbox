---
name: jira-create-bug
description: Create a Jira Bug from an investigation, a Sentry issue, a log or a user report, with human steps to reproduce, expected and actual behaviour, a one-line cause and a definition of done. Use when the user says "create a bug", "open a bug", "make a ticket for this" or "/jira-create-bug". Never create a ticket on your own initiative, for example at the end of an investigation: wait for the user to ask.
---

# Create a Jira bug

The ticket is read by a product manager, a QA or a developer of another team. They must be able to reproduce the bug by clicking in the product, without reading code.

## Before writing

1. Load the `writing-for-humans` skill. Its rules apply: English, no em dash, no semicolon, no two-column table, conclusion first, about 150 words outside the steps.
2. Reuse what the conversation already holds. After an investigation (a `/sentry-analyzer` run, a log dig), take the Sentry link, count, first-seen date, example id, root cause and `path:line` from it, and do not fetch them again. If the user picked one of the proposed fixes, the "Suggested fix" is that one, not your own recommendation. If something is still missing, find it yourself before asking:
   - **Who** is blocked (which user role) and **on which screen**.
   - **Which data** triggers it (an origin, a status, a country, a flag). Find it in the code, not by guessing.
   - **A real example** from Sentry, Datadog or the user (an id, a URL).
   - **Volume**: occurrence count and first-seen date, if a Sentry issue exists.
3. If you could not reproduce the bug yourself, say so to the user (not in the ticket).

## Ticket content

**Summary**: the symptom as the user sees it, never the exception. Good: "Duplicating an archived project fails with an error on the dashboard". Bad: "IllegalStateException in ProjectDuplicationService".

**Description** (markdown), in this order:

```markdown
<1–2 sentences: who cannot do what, and what they see.>

Seen <N> times in production since <date>, <still happening | stopped on date> ([Sentry <SHORT-ID>](<url>)).

## Steps to reproduce

1. Log in to <screen> as <role> of <the data that triggers it>. Example in production: <id>.
2. <Precondition that makes the action available.>
3. Click **<Action>**.

**Expected:** <what should happen, in product words>.

**Actual:** <what the user sees>.

<Other cases affected, one line, only if any.>

## Cause

<One or two sentences in plain words, with one `path:line` reference. Say whether data is corrupted or not.>

## Definition of done

- <Observable product behaviour that proves the fix.>
- Suggested fix: <the recommended option, one line, with the test that covers it>.
```

Steps use UI words (button labels, screen names), never endpoints or class names. Code references appear only in the Cause section.

## Creating it

- Settings: read `.ai-toolbox.yaml` at the repo root if it exists, else `~/.config/ai-toolbox/config.yaml` (format: `config.example.yaml` in the ai-toolbox repo). Keys used: `jira.cloudId`, `jira.defaultProject`.
- Atlassian MCP, `cloudId` = `jira.cloudId`. A missing key → stop and say which one.
- Project `jira.defaultProject` unless the user names another. Issue type `Bug`: check the project's issue types with `getJiraProjectIssueTypesMetadata` first, the name may be localized.
- Call `createJiraIssue` with `contentFormat: "markdown"`. Do not set the assignee, priority or sprint unless the user asks.
- When the user asked to create the ticket, create it directly, no draft round-trip.

## After creating

Reply with the key as a link, the summary, and a 3-bullet recap of what the ticket contains. Mention anything you could not verify (for example, steps not reproduced by hand).
