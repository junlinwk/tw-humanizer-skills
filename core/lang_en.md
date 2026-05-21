# English-Specific Patterns (lang_en.md)

**Load this file when the output language is English.**

Pairs with `universal.md`. Contains English-specific AI fingerprints not covered by universal rules.

---

## 1. English Vocabulary Blacklist

Banned across all contexts:

### Core AI vocabulary (highest priority)
delve, delving, delved, leverage, leveraging, utilize, utilizing, utilization, comprehensive, robust (overused), seamless, seamlessly, streamline, streamlined

### Mid-tier AI vocabulary
holistic, nuanced, intricate, pivotal, paramount, tapestry, multifaceted, foster, empower, unleash, navigate (metaphorical)

### Corporate-speak / buzzwords
synergy, synergies, paradigm, paradigm shift, ecosystem (corporate sense), stakeholder, stakeholders, actionable, actionable insights, best practices, going forward, at the end of the day, circle back, touch base, low-hanging fruit, move the needle, game-changer, cutting-edge, state-of-the-art, innovative, revolutionary, groundbreaking, transformative

### Inflated adjectives
powerful, elegant, comprehensive, sustainable, scalable, dynamic, strategic, best-in-class, next-generation, world-class

---

## 2. English Sentence Pattern Blacklist

### Generic opener / closer clichés
- "In today's fast-paced world"
- "In the ever-evolving landscape of..."
- "In recent years, there has been growing interest in..."
- "With the rapid development of..."
- "Let's dive into..."
- "In this article, we will explore..."
- "In conclusion / In summary / To summarize"

### Filler phrases
- "It's worth noting that"
- "It's important to note that"
- "It's important to remember"
- "It is interesting that..."
- "Notably,..."

### "It is X that Y" filler constructions
- "It is observed that..."
- "It can be seen that..."
- "It should be noted that..."

### AI assistant self-reference (strongest tell)
- "As an AI" / "As a language model"
- "I would be happy to..." → use "I'd love to" / "happy to"
- "I cannot" → use "I can't"
- "Feel free to ask..."
- "Great question!" / "Excellent question!"
- "Certainly" / "Absolutely" (overused affirmations)
- "I hope this email finds you well"
- "Do not hesitate to..."
- "Please be advised..."
- "At your earliest convenience"

### Other patterns
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

---

## 18. Lack of Contractions = AI Signal (Casual / Blog contexts)

In casual English (chat / blog / personal writing), humans use contractions naturally. AI tends to write the formal expanded form.

### Detection
If a piece of casual/blog English ≥ 50 words has **zero** contractions, that's a strong AI tell.

### Common contractions humans use naturally
- don't (not "do not"), can't ("cannot"), won't ("will not")
- I'm, I've, I'll, I'd, you're, you've, we're, we've, they're
- it's, that's, there's, here's, what's, let's
- isn't, aren't, wasn't, weren't, hasn't, haven't, hadn't
- couldn't, wouldn't, shouldn't, didn't, doesn't

### Context rules
- **Casual / blog (1 chat, 8 creative casual)**: contractions strongly expected
- **Student handwritten (C)**: contractions natural, use them
- **Formal student report (D)**: contractions OK in reflection sections
- **Formal application / letter (E)**: contractions avoided (formal register)
- **Academic (F)**: contractions avoided

### Why this matters
AI writes "I do not think" where a human would write "I don't think". The expanded form is grammatically correct but reads robotic in casual contexts.

---

## 19. Over-Formal Phrase Replacements

AI loves padded formal phrases. In casual / blog English, use the shorter human version.

| AI bloat | Human shorter |
|----------|--------------|
| "in order to" | "to" |
| "due to the fact that" | "because" / "since" |
| "in the event that" | "if" |
| "for the purpose of" | "to" / "for" |
| "with regard to" | "about" / "on" |
| "pertaining to" | "about" / "regarding" |
| "in light of" | "given" / "because of" |
| "in terms of" | "for" / "when it comes to" |
| "on the other hand" | "but" / "then again" |
| "at this point in time" | "now" / "currently" |
| "prior to" | "before" |
| "subsequent to" | "after" |
| "in the near future" | "soon" |
| "utilize" | "use" |
| "endeavor to" | "try to" |
| "in addition to" | "besides" / "plus" |
| "with the exception of" | "except" |
| "in spite of" | "despite" |
| "regarding the matter of" | "about" |

Formal contexts (E, F): some of these may be appropriate. But "utilize" → "use" applies everywhere — "utilize" almost always reads as AI bloat.

---

## 20. Perfect Intro / Outro Markers (Structural AI Tell)

Detecting AI-written articles via opening / closing patterns:

### Intro markers (AI often opens with these)
- "In this article, we will..."
- "This article explores..."
- "Today, we'll be discussing..."
- "Let's explore..."
- "We will examine..."

### Outro markers (AI often closes with these)
- "In conclusion,..."
- "To summarize,..."
- "In summary,..."
- "Overall,..."
- "To wrap up,..."

### Human alternative
Just start with content. End with a specific concrete point or unresolved question. The frame itself signals AI.

---

## 21. Semicolon / Em-dash Overuse (Punctuation Tell)

AI English shows specific punctuation tics:
- **Em dash (—)** used heavily as stylistic separator (already covered in `universal.md` §9)
- **Semicolon (;)** used to chain clauses where a period would do
- Ratio test: (semicolons + em-dashes) ÷ sentences > 0.3 = likely AI

Humans writing casually rarely use semicolons. Academic writing uses them, but sparingly.
