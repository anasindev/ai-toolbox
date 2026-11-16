---
name: asking-the-user
description: Load BEFORE asking the user any question during a task — clarification, trade-off, implementation choice, AskUserQuestion, "I'll let you decide" — including a short question, and as soon as they reply "I didn't understand anything" or "this is incomprehensible".
---

# Asking the user a question

The user is a developer. What blocks them is **neither** technical vocabulary **nor** missing context: it is **VOLUME** and **ABSTRACTION**. A "business-level" question with no real names got "I didn't understand ANYTHING". The same question in three sentences with the real names was decided on the first try.

Single source of truth for the **form** of questions: this skill overrides any other template.

## Before asking: is it really a question?

- The answer is in the code, the ticket, the git history or prod → **go read it**, don't ask.
- The choice is technical with no observable effect → **decide alone**, mention it in the deliverable.
- I need to explain an internal mechanism for the question to make sense → the question is **badly framed**. Reframe it, or ask the user to state the need in their own words.

## The template — in this order, nothing else

1. **The fact** (1 to 3 sentences): what happens today, with the **real names** and **a measured number** if one exists.
2. **The question** (1 sentence, ends with "?").
3. **The options** (2 to 4, **one line each**): short label, then what it concretely gives.
4. **My recommendation** (1 sentence): which one, and why.

**Hard cap: 150 words**, options included. Nothing before point 1, nothing after point 4. Write in **normal prose**: caveman mode stays active for the rest of the turn, not for the question.

## Names: the real ones, never a paraphrase

Every name used comes from one of these four sources: the user's words in the conversation, the Jira ticket, an identifier in the code, a label visible on screen. **A name that comes from none of the four is an invented name**: replace it with the real one, or remove it.

**Never** translate a real name into a "business" paraphrase: `payout` does not become "the starting point", a reception event does not become "the marker". That is exactly what makes a question unreadable. A real name they may not know is defined **once, in four words in parentheses**.

## "I didn't understand anything"

This is **not** a request to rephrase the same question more simply. It is the signal that **my framing of the problem is wrong**.

- Don't rewrite the same question shorter: change the framing, or ask "tell me the need in your own words".
- As soon as they state the need themselves, **their sentence becomes the instruction**: reuse it verbatim, search for it as-is in the code, drop my framing. Don't try to reconcile it with my previous options.

## Option labels

One label = **one single** scope. The user answers the label, not the description. "A + B" = two options, never one. An option that widens the scope says so **in its label**.

## Example

❌ **What failed**

> Today the processing starts from a starting point that is not always filled in. When this marker is missing, the covered period can no longer be determined, which opens a trade-off between exhaustiveness and reprocessing cost. A recovery strategy must be chosen, knowing that each one has implications on load and on data consistency. [+ 2 paragraphs]

✅ **What worked**

> The fan-out cursor is the payout's reception event. 12% of payouts in prod don't have one, so they never go out.
>
> What do we do with these 12%?
>
> - **Replay them from their creation date** — all processed, risk of duplicates on those already sent.
> - **Leave them out and alert** — zero duplicates, but manual recovery.
>
> Recommendation: replay them, duplicates are caught downstream.

## Red flags — rewrite before sending

- More than 150 words, or more than two questions in the turn.
- A name I can't point to in their words, the ticket, the code, or the screen.
- "Basically", "in other words", "it's a bit like", a scenario, an analogy.
- A paragraph "why I can't decide alone".
- An option I would never choose, added to pad the list.
- A reference ("see the ticket", "see this file"): the question is self-contained.
- A code block, unless the question is **about** those exact two lines.
