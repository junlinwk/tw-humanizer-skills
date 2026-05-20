# Preset E: Formal Academic Writing (English)

## Scope
- Research papers (journals, conferences)
- Thesis chapters / dissertations
- Literature reviews
- Technical reports (formal)
- Grant proposals
- Academic book reviews

## Note on Language

Formal academic publishing is predominantly in English. **This preset is written in English and focused on English academic conventions.**

For Chinese academic writing (which has its own 文白夾雜 conventions), see `core/lang_zh.md` §6 plus this preset's structural principles. But the sentence-pattern guidance below is English-specific.

## Core Principle

**Specific over general. Active over hedged-passive when truthful. Hedge only when uncertain.**

Academic writing's job is to make claims that survive peer scrutiny. AI academic writing fails by:
- Vague claims that say nothing concrete
- Over-hedging to avoid commitment
- Padding with throat-clearing phrases
- Citing "many studies" without specifics

---

## Rule Table

| Dimension | Rule |
|-----------|------|
| Sentence length | Varied (mixed short and long) |
| Voice | Active when truthful; passive only when agent is irrelevant |
| Em dash | ≤ 3 per piece (allowed but watch overuse) |
| Contrast structure ("not X, but Y") | ≤ 2 per piece |
| Self-Q&A | ≤ 1 (opening rhetorical only) |
| First-person | Field-dependent (CS often allows "we"; humanities varies) |
| Hedging | One per claim, no stacks ("may possibly") |
| Citations | Specific (author + year). Never "many studies" |
| Concrete data | Required (numbers, datasets, methods) |
| Closing clichés | Banned (no "further research is warranted") |
| Field jargon | Allowed but explained on first use |

---

## Banned AI Academic Sentence Patterns

These are the highest-frequency AI academic tells. **Avoid all of them.**

### 1. Throat-clearing openings

- "In recent years, there has been growing interest in..."
- "With the rapid development of X..."
- "X has become increasingly important..."
- "In the era of X..."
- "Over the past decade..."

**Replace with**: a specific claim that motivates the work.

### 2. Vague generality claims

- "It is widely acknowledged that..."
- "Many studies have shown..."
- "It is generally believed that..."
- "There exists a substantial body of literature on..."
- "X plays a pivotal / crucial / key role in..."

**Replace with**: a specific citation or quantified claim.

### 3. Filler hedging phrases

- "It is important to note that..."
- "It is worth mentioning that..."
- "Notably,..."
- "It is interesting that..."

If it's worth noting, just note it. The flag is redundant.

### 4. Vacuous contribution claims

- "This study aims to..."
- "This work makes the following contributions: 1. ... 2. ... 3. ..."
- "We propose a novel framework that..."
- "To the best of our knowledge, this is the first..."

**Replace with**: a specific statement of what is new and why it matters.

### 5. Empty closings

- "Further research is warranted / needed."
- "We hope this work will inspire future research."
- "Future work should explore..."
- "This area deserves more attention."

If you mean a specific extension, **state it specifically**. Generic gestures toward "future work" signal nothing.

### 6. Hedging stacks

- "may potentially"
- "could possibly"
- "might somewhat"
- "tends to perhaps"

**Rule**: one hedge per claim, max. Stacking signals AI text.

### 7. Adjective inflation

- "novel" (used loosely)
- "comprehensive", "rigorous"
- "robust", "scalable" (without metrics)
- "groundbreaking", "state-of-the-art", "cutting-edge"

Use these only when backed by specifics. "ResNet-50 trained on 1.4M images" justifies "comprehensive"; otherwise drop the adjective.

### 8. The "It is" stack

- "It is observed that..."
- "It can be seen that..."
- "It should be noted that..."
- "It is reasonable to assume..."

Most "It is X that Y" constructions are filler. Just write the Y.

### 9. Triple parallels (overused in English AI)

- "fast, efficient, and scalable"
- "novel, comprehensive, and robust"
- "robust, intuitive, and powerful"

Vary with 2 or 4 items. Avoid making triplets the default rhythm.

### 10. Pronoun "we" used to absorb the reader

- "As we navigate the complexities of..."
- "We must consider..."

In academic writing, "we" should mean the authors. Don't pull the reader into your conclusions.

---

## Recommended Sentence Patterns

### State claims directly
- ❌ "It can be observed that the model achieves higher accuracy."
- ✅ "The model achieves 94.2% accuracy on CIFAR-10."

### Specific citations
- ❌ "Many studies have shown the importance of X."
- ✅ "Smith et al. (2022) and Chen (2023) both find that X."

### Hedge once, deliberately
- ❌ "Our results may possibly indicate some preliminary evidence of..."
- ✅ "Our results suggest..." (pick one verb, commit)

### Acknowledge limitations explicitly
- ❌ "Some limitations may apply."
- ✅ "Our sample is limited to 200 undergraduates at a single institution; generalization to working professionals requires replication."

### Describe methods concretely
- ❌ "Various techniques were employed."
- ✅ "We trained ResNet-50 for 90 epochs with SGD, learning rate 0.1, batch size 256."

### Direct results
- ❌ "The results demonstrate the efficacy of the proposed approach."
- ✅ "The proposed approach reduces inference latency from 230ms to 80ms (p < 0.001, paired t-test, n = 1000)."

### Section openers
- ❌ "In this section, we discuss the experimental setup."
- ✅ "Section 3 presents the experimental setup." OR just begin: "We trained ResNet-50 on..."

---

## Voice and Person

Field conventions vary. **Pick one and stay consistent.**

**Active "we"** (common in CS, ML, engineering):
> "We propose..." "We evaluate..." "We find..."

**Passive impersonal** (common in chemistry, biology, formal humanities):
> "The proposed method was evaluated against three baselines..."

**First-person "I"** (some humanities, single-author philosophy):
> "I argue..." "I show that..."

Avoid:
- Mixing voices within one section
- Excessive passive that masks agency: ❌ "It was decided to use X" (by whom?)

---

## Hedging Discipline

Hedging is appropriate when uncertainty is real. AI's tell is **hedging when the claim is actually certain**, to seem modest.

### Appropriate hedging
- "Our findings suggest X, though the effect size was small (d = 0.18)."
- "This pattern is consistent with Y, but causal interpretation requires replication."

### Inappropriate hedging
- "It may be that the model possibly achieves better accuracy" — the model either does or doesn't.
- "This study could potentially contribute to understanding X" — either it does or it doesn't.

**One hedge per claim. Pick: "suggests" OR "may indicate" OR "is consistent with" — don't stack.**

---

## Citation Practices

### Specific over vague
- ❌ "Recent work has shown..."
- ✅ "Recent work (Smith et al., 2022) has shown..."

### Don't bury the point
- ❌ "It has been shown (Smith, 2022; Chen, 2023; Lee, 2024; Park, 2024; Wong, 2023; Liu, 2024) that X."
- ✅ "Three independent groups (Smith, 2022; Chen, 2023; Lee, 2024) report X." Or limit to the 1-2 most relevant.

### Every citation should do work
If a reference doesn't support the specific point in the sentence, cut it.

---

## Concrete Specificity Floor

Each paragraph should have at least one of:
- Specific number (sample size, effect size, performance metric)
- Specific reference (author + year)
- Specific tool / method name (with version when relevant)
- Specific dataset / location / time period

Without these anchors, the paragraph is probably padding.

---

## The "I Don't Know" Move

Universal Rule 0 (`core/universal.md` §0) applies with full force in academic writing. Honest academic writing requires admitting:

- Methodological limitations
- Bounds of generalization
- Unresolved tensions in your data
- What you did not test

Examples:
- "Our manipulation check failed to differentiate condition A from B; this limits our ability to interpret the main effect."
- "The replication used a different operationalization of X, which may explain the divergent results."
- "We do not have data on Z, which a complete model would require."

This is **strength**, not weakness. AI text typically hides limitations behind hedging stacks.

---

## Example: AI Academic vs Human Academic

### ❌ AI Academic
> In recent years, there has been growing interest in transformer-based language models. These models have revolutionized natural language processing and demonstrated unprecedented capabilities across various tasks. In this paper, we propose a novel framework that leverages transformer architectures to address several key challenges in the field. Our comprehensive experiments on a wide range of benchmarks demonstrate the efficacy of the proposed approach. We hope this work will inspire future research in this exciting area.

**AI tells**: "growing interest", "revolutionized", "unprecedented", "novel framework", "leverages", "comprehensive", "demonstrate the efficacy", "exciting area". Many words, almost no content.

### ✅ Human Academic
> Transformer architectures (Vaswani et al., 2017) dominate current NLP benchmarks, but their O(n²) attention complexity makes them costly on sequences longer than ~10k tokens. Several recent approaches address this — Linformer (Wang et al., 2020), Performer (Choromanski et al., 2021), and FlashAttention (Dao et al., 2022) — each trading something for speed: approximation accuracy, kernel design constraints, or hardware specificity. We test whether a simpler approach, sliding-window attention with learned global tokens, matches their performance on three long-context benchmarks (PG-19, arXiv-long, GitHub-code). The method matches FlashAttention's speed within 8% while being implementation-simpler. We also report a failure case: on tasks requiring precise long-range retrieval (NarrativeQA), the method loses 4.2 F1 points relative to FlashAttention. Section 5 discusses why.

**Human signals**: specific complexity ("O(n²)"), specific threshold ("~10k tokens"), specific cited methods with named tradeoffs, specific benchmarks, concrete results (8% gap, 4.2 F1 drop), **honest failure case acknowledged**, forward-reference to Section 5 instead of vague "future work".

---

## Self-check (post-writing)

Before submitting, verify:

- [ ] No "In recent years..." or "With the rapid development of..." opening
- [ ] No "many studies have shown" without specific citations
- [ ] No "novel / comprehensive / groundbreaking" without specific justification
- [ ] No double-hedging ("may potentially", "could possibly")
- [ ] No "further research is warranted" closing
- [ ] No "we hope this work will inspire..."
- [ ] No "It is X that Y" filler constructions (find and rewrite)
- [ ] Voice consistent throughout (pick active "we" / passive / first-person "I")
- [ ] Each paragraph has at least one specific anchor (number / citation / method / data)
- [ ] Limitations explicitly stated, not hidden
- [ ] Em dash ≤ 3 in whole paper
- [ ] Triple-parallel structures ≤ 2 in whole paper
- [ ] Universal Rule 0 honored: uncertain things marked uncertain, not dressed as certain

Pass ≥ 10 to consider acceptable.

---

## Comparison with Other Presets

| Aspect | D Student Report | **E Academic** | C Formal Application |
|--------|------------------|----------------|----------------------|
| Personal voice | Encouraged | Restrained (field-dependent) | Personal but formulaic |
| Colloquial transitions | "老實說" OK | No | No |
| Bracket asides | "(I forgot the year)" OK | Move to footnote / explicit limitation | No |
| Citations | Optional | **Required** | No |
| Limitations | Informal, in reflection | Explicit, formal section | Not applicable |
| Sentence rhythm | Varied, can be loose | Varied but tighter | Standard formal |

---

## Cross-references

- `core/universal.md` §0 — admit uncertainty (apply rigorously in limitations)
- `core/universal.md` §3 — hyperbole watch (academic-specific examples here)
- `core/lang_en.md` — full English AI vocabulary + sentence-pattern blacklists
- `core/lang_zh.md` §6 — Chinese academic conventions (文白夾雜) if writing in Chinese
