# English-Specific Patterns (lang_en.md)

**Load this file when the output language is English.**

Pairs with `universal.md`. Contains English-specific AI fingerprints not covered by universal rules.

---

## 1. English Vocabulary Blacklist

Banned across all contexts:

delve, leverage, robust (when overused), seamless, holistic, nuanced, intricate, pivotal, paramount, tapestry, multifaceted, foster, empower, unleash, navigate (metaphorical), ecosystem (corporate-speak)

---

## 2. English Sentence Pattern Blacklist

- "In today's fast-paced world"
- "In the ever-evolving landscape of..."
- "Let's dive into..."
- "It's worth noting that"
- "It's important to remember"
- "As we navigate..."
- "It's not just X, it's Y" — **THE ChatGPT signature, avoid completely**

---

## 3. English Contrast Structure (Soft Limit, density varies by preset)

- "Not X, but Y"
- "X is not about A, it's about B"
- "It's less about X and more about Y"
- "X is not just Y" / "It's more than X"

Occasional use is fine. Consecutive use or main narrative rhythm = strong AI signal.

---

## 4. English Self-Q&A Patterns

Soft limit ≤ 1 (per universal.md rule).

AI consecutive style (banned):
- "Why does X matter? Because..."
- "What's the solution? Well..."
- "So how do we fix this? The answer is..."

Allowed human style (≤ 1, opening rhetorical):
- "Why did I want to take this class? Because I've been interested in quantum physics since middle school."

---

## 5. Em Dash Heavy Use (English-Specific Watch)

Claude's strongest English signal. People rarely type em dashes in casual writing — they use commas, periods, parentheses, or semicolons.

Limits by context:
- Casual / blog: 0 em dashes preferred
- Formal / academic: ≤ 2-3 per piece
- Email / chat: 0

Detection note: AI also often inserts en-dash (–) and hyphen (-) interchangeably. Stick with whatever the user uses, or default to plain commas.

---

## 6. English Closing Clichés (Banned)

- "In conclusion"
- "Ultimately"
- "To sum up"
- "All in all"
- "At the end of the day"

**Exception**: Conclusions with specific concrete callbacks to earlier points are fine.
- ❌ "In conclusion, AI will transform our future."
- ✅ "Together, these three findings (the latency spike, the memory leak, and the test gap) suggest X."

---

## 7. English Hyperbole (Banned without data)

- the biggest, the most, the only
- fundamentally, completely, entirely
- revolutionary, game-changing, transformative
- all of, every single, ultimate, paramount

**Exception**: Backed by explicit numbers / evidence.
- ❌ "This is the biggest change in software architecture."
- ✅ "Of the 30 engineers I interviewed, 22 had never heard of X."

---

## 8. English Abstract Word Stacking (Banned without concrete support)

- powerful, elegant, robust (marketing sense)
- cutting-edge, world-class, state-of-the-art
- comprehensive, holistic, scalable, sustainable
- innovative, dynamic, strategic
- best-in-class, next-generation

---

## 9. Triple Parallel Structure Overuse

English AI loves "X, Y, and Z" patterns:
- "Fast, reliable, and secure"
- "Building, scaling, and maintaining"
- "Robust, intuitive, and powerful"

Watch density — vary with 2 or 4 items occasionally. Avoid making this the default rhythm.

---

## 10. Title-Case Inflation

AI English over-uses Title Case for emphasis. Examples:
- ❌ "We Need to Build Strong Foundations" (mid-paragraph)
- ✅ "we need to build strong foundations"

Use sentence case unless it's a genuine headline or title.

---

## 11. Smart-Quote Inconsistency

AI mixes "smart quotes" (curly: " " ' ') with straight ('). Human writing tends to be consistent.

- In casual / tech contexts: straight quotes common
- In formal / literary contexts: smart quotes common
- Pick one and stay consistent

---

## 12. Hedging Stack (Double-Hedging)

Double-hedging is an AI tic:
- ❌ "can potentially"
- ❌ "may sometimes"
- ❌ "tends to often"
- ❌ "might possibly"

One hedge per claim, max.

---

## 13. "We" Pronoun Overuse

AI English often uses "we" to falsely pull the reader in:
- "As we navigate the complexities of..."
- "We must consider..."
- "Let's explore..."

In tech blog / personal writing, prefer "I" or just state the point directly.

---

## 14. Adverb Inflation

AI loves modifier adverbs that add no information:
- "extremely", "incredibly", "remarkably", "particularly", "notably"
- "fundamentally", "essentially", "basically"

Use only when truly modifying the claim.

---

## 15. Overuse of "Furthermore / Moreover / Additionally"

These are AI's signature transition words:
- ❌ Three different transition words within four sentences
- ✅ Use plain "and", "also", "but" or no transition at all

If you find yourself reaching for "Moreover" — consider whether the sentence needs a transition at all.

---

## 16. The "It's Important to Note" Family

- "It's important to note that..."
- "Worth mentioning is..."
- "One key consideration is..."
- "Notably..."

If it's important, just state it. The flag is redundant.

---

## 17. Ending Sentences with "...and beyond" / "...and more"

- ❌ "from healthcare to finance and beyond"
- ❌ "for developers, designers, and more"

Lists either end concretely or with "etc." — not vague extension.
