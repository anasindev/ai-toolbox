---
name: writing-for-humans
description: Load BEFORE writing any document meant to be READ by a human — RFC, Notion note or page, Jira description and comment, MR description, report, analysis, delivered markdown doc, long Slack message — in English or French.
---

# Writing a document read by a human

The default reader is **non-technical** and will only read the beginning. The document serves **a decision**, it is not a replay of my exploration.

## The template

1. **One conclusion sentence at the top**: what the document says, asks or decides. The reader must be able to stop there.
2. **The body, only on the announced subject.** One idea per paragraph, 3 to 5 lines, white space between blocks.
3. **What happens next**, when there is a decision: who decides what, and when.

## The scope filter — before each paragraph

> Which decision of **THIS** document changes if I delete this paragraph?

None → it goes. This also applies to **accurate** facts found while exploring: another project, another country, the history of a neighbouring enum, a precedent from another team. They stay in my answer to the user, never in the document.

## Length

| Document | Target | What goes in |
|---|---|---|
| Jira comment | 100 words | the new fact, the decision, nothing else |
| Jira description | 150 words | the need as seen by the end user, the DoD |
| MR description | 200 words | what changes, for whom, how to verify it |
| Report, analysis | 400 words | the conclusion, the numbers that support it |
| RFC, decision note | 2 pages | the problem, the options, the recommendation |

The length is that of the **subject**, never that of my exploration. One more chapter is not proof of seriousness.

## Project vocabulary

**One concept = one word, the project's word**, kept identical from start to finish. The word comes from the ticket, the code, the screen, or what the user wrote. Two names for the same thing in one document make it unreadable, and varying vocabulary "for style" is a fault, not elegance. An unavoidable internal term is defined once, in half a sentence, at its first appearance.

## Technical audience

By default, a sentence states **the observable effect** (what the end user sees, what changes in the data, the delay, reversibility), not the mechanism. Technical detail goes in an appendix, a toggle or a sub-page.

If the user says **the audience is technical**, technical depth is allowed in the body: class names, `path:line`, schemas, queries. The template, the lengths and the tics below stay unchanged.

## AI writing tics — remove them

- **Em dash or en dash as an aside.** Use a comma, parentheses, or a separate sentence.
- **Semicolons.** Replace with a full stop.
- **Seesaw phrasing**: "it's not X, it's Y", "it's not just about…", "more than an X, a Y".
- **Empty transitions**: "in summary", "it is important to note that", "it is worth noting", "let's dive into".
- **Decorative emphasis**: bold on random words, emoji in headings, overlong enumerations.
- **Two-column tables.** A table is justified from three columns. With two, use a labelled bullet: `- **Label.** Explanation.`

Check before delivering, on the written file (ignore occurrences inside code blocks):

```
grep -nE '—|–|;|[Ii]n summary|important to note|worth noting|[Ll]et.s dive' doc.md
```

## Zero construction metadata

The document is a **final deliverable**: the reader has no clue how it was written. Banned from published text: headers describing what the section should contain, drafting checkboxes, "to be written" placeholders, comments about the document itself, any restatement of the instructions received.

## Red flags — rewrite before delivering

- The conclusion is not in the first two lines.
- A paragraph that serves no decision of this document.
- Two different words for the same concept.
- An em dash, a semicolon, a two-column table.
- Technical detail in the body when the audience wasn't stated as technical.
- The document is longer than its type's target.

## Language

Everything sent to Jira, GitLab or Notion is written in **English**. The rules above are identical in both languages.
