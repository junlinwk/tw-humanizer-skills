# detector — Fast-DetectGPT scoring for tw-humanizer

零次學習（zero-shot）的 AI 文字偵測器，採用 Fast-DetectGPT 解析版本（analytical variant）。

## 在 skill 架構中的位置（重要）

這是 **Layer 2：opt-in 重度檢測**，給「真的要避開商業偵測器」的場景用。

| Layer | 是什麼 | 何時用 | 成本 |
|-------|--------|--------|------|
| 0 | 寫作規則本身（core/ + presets/ + contexts/） | 永遠開啟 | 零 |
| 1 | `self-check.md`（7 維度啟發式打分） | 預設品管層，長文後跑 | 幾百 token |
| **2** | **本目錄（Fast-DetectGPT 機器評分）** | **用戶要過 GPTZero / Turnitin / Originality 時才用** | torch + 3GB 模型 + GPU 時間 |

**絕對不是 D / E / F preset 的預設流程**。Layer 1 已經涵蓋「看起來不像 AI」這個目標，多數情境跑到 Layer 1 就夠了。Layer 2 是當你準備把文章丟進商業偵測器、想要實際數值化評估時才出動。

**現階段（Phase 1）**：CLI 評分器，**只回分數，不改文章**。loop 與重寫機制在後續階段疊加。

## 觸發訊號（用戶說以下話時才考慮跑）

- 「要交 Turnitin」「過 GPTZero」「Originality 會跑」
- 「跑機器評分」「用 fast-detectgpt 測一下」「給我一個 AI 分數」
- 「去 AI 味到底」「跑到能過為止」
- 用戶明確點名 detector / 機器偵測器

**反之，這些訊號不該觸發 Layer 2，跑 Layer 1 就好**：
- 「幫我寫一份報告」（D preset 但沒提偵測 → Step 7 即可）
- 「寫一封信給教授」（E preset → Step 7 即可）
- 「人性化一下」「去 AI 味」（一般用詞 → Step 7 即可，除非用戶後續強調機器偵測）

---

## 設計約束（核心，不可違反）

以下約束源自跟使用者對齊後的設計決策，任何後續疊加功能都必須遵守：

### 1. Bounded iterations（收斂）
- 重寫迭代硬上限：4 次
- 達到任一停止條件即停：
  - `score < preset threshold`
  - `Δscore > -0.03`（兩次間下降不足 3%）
  - 連續 2 次 `top_fingerprints` 完全相同（卡住了）

### 2. Fact preservation（保證文章正確性）
重寫前先抽取 fact anchors，鎖死不准改：

| 類別 | 範例 |
|------|------|
| 數字 / 百分比 / 日期 | `80%`、`2024`、`n=5`、`120ms` |
| 直接引用 | 引號 / 「」 內的字串 |
| 引用標記 | `(Author, 2024)`、`[1]` |
| 課程 / 競賽 / 機構 | `CS 6210`、`學測 56 級分` |
| 程式碼 / 公式 | `code`、`O(n²)`、`Q, K, V` |
| 專有名詞 | `FlashAttention`、`Cook-Levin`、`Qwen2.5` |

每個 token 標記 `mutable: true/false`，重寫只能動 `mutable=true` 範圍。

### 3. Word / sentence-level edits only（不重寫結構）
- 每次 loop 最多改 3 個句子
- 不刪段、不加段、不重排
- 不改章節標題、不動列表結構
- 純粹詞句層級的 humanize 替換

---

## Phase 規劃

| 階段 | 範圍 | 狀態 |
|------|------|------|
| **Phase 1** | CLI 評分（Fast-DetectGPT 解析版） | 進行中 |
| Phase 2 | Stylometric 指紋規則（reverse `lang_zh/en.md`），輸出 `top_fingerprints` | 待開始 |
| Phase 3 | 整合到 SKILL.md Step 5.5，手動觸發 | 待開始 |
| Phase 4 | 自動 loop + fact anchor + 句層級重寫 | 待開始 |
| Phase 5 | Threshold 校準（用 ai-vs-human 範例庫做驗證集） | 待開始 |

---

## 演算法（Phase 1）

Fast-DetectGPT 解析版（analytical sampling discrepancy）— 不需要採樣，直接從 softmax 計算期望值與變異數。

### 數學

對輸入文本 `x = [x₁, ..., x_n]` 與評分 LM `p`：

對每個位置 `i`：
- 實際 log prob：`logp_i = log p(xᵢ | x<ᵢ)`
- 條件分布的期望 log prob：`μ_i = Σ_v p(v|x<ᵢ) · log p(v|x<ᵢ)` （等於 `-H_i`，負熵）
- 條件分布的 log prob 變異數：`σ²_i = Σ_v p(v|x<ᵢ) · (log p(v|x<ᵢ))² − μ²_i`

文件層級 z-score：
```
z = (Σ logp_i − Σ μ_i) / √(Σ σ²_i)
```

**直覺**：
- 若 `x` 由同分布的 LM 採樣產生 → z ≈ 0
- 若 `x` 為貪婪 / 低溫採樣產生（AI 典型）→ z > 0，且越大越像 AI
- 若 `x` 含 LM 預期外的詞 → z < 0，偏向人類

跟原版 DetectGPT 差別：
- DetectGPT：對 x 做擾動再比較 → 慢（100+ forward pass）
- Fast-DetectGPT（採樣版）：從同 LM 採樣替代 → 快（10-20 forward pass）
- **解析版（本實作）**：直接從 softmax 算期望 → 1 個 forward pass，等價於採樣 →∞

### 為何用解析版

採樣版本的 expected log prob 是：
```
E_{x̃ ~ p(·|x<ᵢ)} [log p(x̃ | x<ᵢ)]
```
這個期望可以**解析計算**為：`Σ_v p(v) log p(v)`（即負熵），無需 Monte Carlo。同理 variance 也可解析。

所以 Fast-DetectGPT 在無限樣本下退化為解析公式，本實作直接用解析公式，省掉採樣噪音與計算成本。

---

## 限制與已知盲區

### F preset 天生高分
學術正式寫作 perplexity 本來就低（句法保守、用詞精準），z-score 會偏高。**這不是 bug，是學術寫作的本質**。

→ 解法：F 的 threshold 設 40-50%，不要試圖把學術文壓到一般 threshold。

### Scoring model 與生成 model 不能同源
若用 Claude 生成、Claude 評分 → 盲區（同模型相互盲）。
本實作預設用 open-source LM（Qwen2.5 / LLaMA-3）當 proxy，理論上對 Claude / GPT-4 偵測仍有效（token distribution 跨模型相關性高），但會掉 10-15% AUC。

### 短文本
< 50 tokens 時所有方法都不準。本實作會在輸出加 warning。

### 不保證對抗特定商業偵測器
本工具優化 Fast-DetectGPT 分數，不代表 GPTZero / Originality 也會放行。商業引擎是 hybrid，含監督式分類器訓練在他們私有資料。

### 文白夾雜會被誤判為 AI
本 skill 在 F preset 允許文白夾雜（「然」「故」「者」「之」），但這些字 LM 預測機率高，會推高 z-score。
→ Phase 2 stylometric 規則將反向修正：若偵測到合法文白夾雜密度，調降 z-score 權重。

---

## 預設 threshold（待校準）

```yaml
# thresholds.yaml (Phase 5 才用)
A: 0.50   # 私人雜記 — 縮減多，PPL 高，預期 z 很低，但 A 本來就不用偵測
B: 0.40
C: 0.30
D: 0.25
E: 0.25
F: 0.45   # 學術天生高分，給寬鬆 threshold
```

數值為「verdict cutoff」對應 z-score 區間：
- `z > 2.5` → `likely_ai`
- `z > 1.0` → `possibly_ai`
- `z > -0.5` → `ambiguous`
- 否則 → `likely_human`

Phase 5 將用 ai-vs-human 範例庫的 ❌ vs ✅ 對照組校準 cutoff。

---

## Install on demand（預設不裝）

**核心原則**：heavy deps（torch、transformers，加上首次跑 Qwen2.5-1.5B 約 3GB 下載）**預設不安裝**。使用者要評分時才裝。

### Claude 互動協議（給 AI 看的）

當 SKILL.md Step 5.5 要呼叫評分器時，AI **必須先做以下檢查**：

1. 跑 `python -m detector.cli check`
2. 若 `ready: true` → 直接進入評分流程
3. 若 `ready: false` → **詢問使用者**，例如：
   > 偵測器需要安裝 torch 與 transformers（首次執行會下載 ~3GB 的 Qwen2.5-1.5B 模型）。要現在安裝嗎？或是這次跳過偵測直接輸出？
4. 使用者同意才執行 `pip install torch transformers`
5. 使用者拒絕 → 直接輸出，不跑偵測

**不要在沒問過使用者的情況下自動 pip install**。pip install 在公司 / 學校環境可能會影響其他套件、佔磁碟、走 proxy，需要使用者明確同意。

### 安裝指令（使用者同意後執行）

```bash
# 標準安裝
pip install torch transformers

# 或用 requirements 檔
pip install -r detector/requirements.txt

# 若使用者只有 CPU，且希望輕量版本
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install transformers
```

### 使用方式

```bash
# 檢查依賴是否齊全（不需要 torch / transformers 就可以跑）
python -m detector.cli check

# 對檔案評分
python -m detector.cli score path/to/text.txt

# 從 stdin 評分
echo "some text" | python -m detector.cli score -

# 指定模型
python -m detector.cli score text.txt --model Qwen/Qwen2.5-1.5B

# 指定語言（影響預設 scoring model）
python -m detector.cli score text.txt --lang zh
python -m detector.cli score text.txt --lang en

# 指定裝置
python -m detector.cli score text.txt --device cpu
python -m detector.cli score text.txt --device cuda
```

### Exit codes

| Code | 意義 |
|------|------|
| 0 | 成功 |
| 1 | `check` 偵測到缺少依賴 |
| 2 | `score` 被呼叫但依賴缺失（stderr 會印 install hint JSON） |

### 輸出格式

```json
{
  "z_score": 2.34,
  "perplexity": 12.5,
  "avg_log_prob": -2.53,
  "n_tokens": 387,
  "model": "Qwen/Qwen2.5-1.5B",
  "verdict": "likely_ai"
}
```

---

## 預設 scoring model

| `--lang` | 預設模型 | VRAM (fp16) | CPU 速度 (500 tokens) |
|----------|---------|-------------|------------------------|
| `auto` | `Qwen/Qwen2.5-1.5B` | ~3GB | ~5-8s |
| `zh` | `Qwen/Qwen2.5-1.5B` | ~3GB | ~5-8s |
| `en` | `Qwen/Qwen2.5-1.5B` | ~3GB | ~5-8s |

升級選項：
- `--model Qwen/Qwen2.5-7B`：精度更高，需要 ~14GB VRAM
- `--model gpt2-large`：純英文 / 無 GPU fallback，~3GB RAM

---

## 參考文獻

- Bao, G., Zhao, Y., Teng, Z., Yang, L., & Zhang, Y. (2024).
  Fast-DetectGPT: Efficient zero-shot detection of machine-generated text
  via conditional probability curvature. ICLR 2024.
  https://github.com/baoguangsheng/fast-detect-gpt

- Mitchell, E., Lee, Y., Khazatsky, A., Manning, C. D., & Finn, C. (2023).
  DetectGPT: Zero-shot machine-generated text detection using
  probability curvature. ICML 2023.
