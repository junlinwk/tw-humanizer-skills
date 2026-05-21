# Test Results: AI Detection Score Validation

跨工具驗證紀錄。用 [humanize-cli](https://github.com/lxgicstudios/humanize-cli) v2.0 作為獨立 AI 偵測工具，跑我們的英文範例。

**目標**：所有範例 AI score ≤ 10%（LOW RISK）。

---

## 測試環境

- 工具：humanize-cli v2.0（5 維度加權：vocabulary 25% / structure 20% / patterns 25% / naturalness 15% / personality 15%）
- Node.js v22.18.0
- 測試指令：`node bin/humanize.js score "TEXT"`

---

## 測試結果（所有範例已優化至 < 10%）

| Sample | Context | AI Score | Status |
|--------|---------|----------|--------|
| Transformer attention（F 學術正式）| Academic technical | **7%** | ✅ LOW |
| NP-completeness（F 學術正式）| Academic theory | **5%** | ✅ LOW |
| Year-end vent（A 私人雜記）| Raw personal journal | **8%** | ✅ LOW |
| Kyoto observation（B 觀察隨筆）| Travel observation | **4%** | ✅ LOW |
| AI baseline（負面對照組）| 含 delve / leverage 等 | 50% | (AI tells confirmed) |

---

## 優化前後對照

### Transformer Attention (F preset)
- **Before**: 20% MODERATE RISK — patterns 40%, personality 50%
- **After**: 7% LOW RISK
- 關鍵修改：
  1. 加 3 contractions：`We've seen`、`it's matching`、`doesn't hold`
  2. 加 1 opinion marker：`Honestly, we think`
  3. Em-dash 從 2 個降到 0

### NP-completeness (F preset)
- **Before**: 24% MODERATE RISK — patterns 40%, naturalness 44%
- **After**: 5% LOW RISK
- 關鍵修改：
  1. 加 3 contractions：`SAT's`、`Here's`、`we'll see`
  2. 加 1 opinion marker：`Honestly, I think`
  3. Em-dash 從 2 個降到 0

### Year-end vent (A preset)
- **Before**: 14% LOW RISK（但 > 目標 10%）
- **After**: 8% LOW RISK
- 關鍵修改：加 1 opinion marker `, honestly`（其他人類訊號已足夠）

### Kyoto observation (B preset)
- **Before**: 11% LOW RISK（但 > 目標 10%）
- **After**: 4% LOW RISK
- 關鍵修改：加 `honestly` 與 `i think the issue wasn't that...` 開頭

---

## 從測試學到的英文寫作 formula

任何英文 preset 要 ≤ 10% AI score，**至少包含**：

1. **2-3 個 contractions**：`I've` `we've` `it's` `doesn't` `won't` `here's` `that's`
   - 即便是 academic（F preset），完全沒有 contractions 會被 humanize-cli 偵測為 AI 訊號
   - 解法：在 framing / discussion 句用 contractions，formal claims 保持不縮

2. **1 個 opinion marker**（命中以下 regex 之一）：
   - `Honestly,...` ← 最自然，幾乎任何 context 都可用
   - `I think...`
   - `In my opinion...`
   - `Personally...`
   - `My take is...`
   - `Here's the thing...`

3. **Em-dash 數量 ≤ 1**：
   - Em-dash `—` 用作風格分隔符是強烈 Claude 指紋
   - 改用逗號、句號、括號、分號

4. **避免 vocabulary 黑名單**：詳見 `core/lang_en.md` §1
   - delve / leverage / comprehensive / robust（過度使用時）/ seamless / utilize / streamline / synergy / paradigm / cutting-edge / state-of-the-art / revolutionary 等

5. **避免 sentence patterns**：詳見 `core/lang_en.md` §2
   - "In today's...", "In recent years...", "In conclusion...", "It's important to note..."

6. **具體性密度**：每 100 字至少 1 個具體名稱 / 數字 / 引用
   - 學術：citations (作者 + 年份)、metric (`O(n²)`)、benchmark name
   - 雜記：地名、日期、具體事件
   - 報告：具體工具、版本、數量

---

## 跟我們 7 維度的對應關係

| humanize-cli 維度 | 我們對應的維度 |
|------------------|--------------|
| vocabulary | Vocabulary (15%) |
| structure | Structure (15%) |
| patterns | Patterns (20%) |
| naturalness | Personality (15%, 含 contractions 子指標) |
| personality | Personality (15%, 含 first-person 子指標) |
| (no equivalent) | **Specificity** (15%) ★ 我們獨有 |
| (no equivalent) | **Narrative** (10%) ★ 我們獨有 |
| (no equivalent) | **Honesty** (10%) ★ 我們獨有 |

humanize-cli 偏向 **casual 寫作**評估（contractions、opinions 是主要 signal）。
我們 7 維度多了 **Specificity / Narrative / Honesty**，補足 humanize-cli 漏掉但對「真實人寫」很關鍵的訊號。

---

## 重新測試指令

如果你要重新驗證：

```bash
# 1. Clone humanize-cli
git clone https://github.com/lxgicstudios/humanize-cli.git /tmp/humanize-cli
cd /tmp/humanize-cli
npm install

# 2. Test a sample
node bin/humanize.js score "your English text here"

# 3. Detailed analyze
node bin/humanize.js analyze "your English text here"
```

---

## 已知限制

1. **中文無法驗證**：humanize-cli 是純英文工具，中文輸出無法用它 cross-check
2. **Academic style 邊界**：humanize-cli 把「無 contractions」當 AI 訊號，但純學術論文確實不太用 contractions。**解法**：在 discussion / framing 句加 2-3 個 contractions，仍然符合學術慣例
3. **偵測會迭代**：humanize-cli 是 rule-based，未來他們黑名單擴充後可能影響分數。我們的 lang_en.md 跟他們的 patterns.js 對齊度高（驗證過），長期應該同步進展
