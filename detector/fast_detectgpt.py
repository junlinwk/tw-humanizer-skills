"""Fast-DetectGPT analytical scorer.

Reference:
    Bao, G. et al. (2024). Fast-DetectGPT: Efficient zero-shot detection
    of machine-generated text via conditional probability curvature. ICLR 2024.

Phase 1 scope: scoring only. This module does not modify text.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

import torch
import torch.nn.functional as F
from transformers import AutoModelForCausalLM, AutoTokenizer


@dataclass
class DetectionResult:
    z_score: float
    avg_log_prob: float
    perplexity: float
    n_tokens: int
    model: str
    verdict: str
    warning: Optional[str] = None

    def to_dict(self) -> dict:
        d = {
            "z_score": round(self.z_score, 4),
            "perplexity": round(self.perplexity, 4),
            "avg_log_prob": round(self.avg_log_prob, 4),
            "n_tokens": self.n_tokens,
            "model": self.model,
            "verdict": self.verdict,
        }
        if self.warning:
            d["warning"] = self.warning
        return d


def _verdict_from_z(z: float) -> str:
    if z > 2.5:
        return "likely_ai"
    if z > 1.0:
        return "possibly_ai"
    if z > -0.5:
        return "ambiguous"
    return "likely_human"


class FastDetectGPT:
    """Analytical Fast-DetectGPT scorer.

    For each token position i with the scoring model's conditional distribution
    p(·|x<i), we compute analytically:
      mean    = Σ_v p(v) log p(v)              (= -H, negative entropy)
      var     = Σ_v p(v) (log p(v))^2 - mean^2
    The document-level z-score is:
      z = (Σ logp(x_i|x<i) - Σ mean_i) / sqrt(Σ var_i)

    This is the no-sampling limit of Fast-DetectGPT — equivalent to taking the
    number of conditional samples to infinity.
    """

    SHORT_TEXT_THRESHOLD = 50  # tokens

    def __init__(
        self,
        model_name: str = "Qwen/Qwen2.5-1.5B",
        device: Optional[str] = None,
    ):
        if device is None:
            device = "cuda" if torch.cuda.is_available() else "cpu"
        self.device = device
        self.model_name = model_name

        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        dtype = torch.float16 if device == "cuda" else torch.float32
        self.model = (
            AutoModelForCausalLM.from_pretrained(model_name, torch_dtype=dtype)
            .to(device)
            .eval()
        )

    @torch.no_grad()
    def score(self, text: str, max_tokens: int = 2048) -> DetectionResult:
        if not text or not text.strip():
            raise ValueError("Empty text")

        encoded = self.tokenizer(
            text,
            return_tensors="pt",
            truncation=True,
            max_length=max_tokens,
        )
        input_ids = encoded.input_ids.to(self.device)

        n_tokens = input_ids.size(1)
        if n_tokens < 2:
            raise ValueError("Text too short — need at least 2 tokens")

        logits = self.model(input_ids).logits

        # Next-token prediction alignment
        shift_logits = logits[:, :-1, :]
        shift_labels = input_ids[:, 1:]

        log_probs = F.log_softmax(shift_logits, dim=-1)
        probs = log_probs.exp()

        # Per-position quantities
        actual = log_probs.gather(2, shift_labels.unsqueeze(-1)).squeeze(-1)
        mean_per_pos = (probs * log_probs).sum(dim=-1)
        var_per_pos = (probs * log_probs.pow(2)).sum(dim=-1) - mean_per_pos.pow(2)
        var_per_pos = var_per_pos.clamp(min=1e-10)

        # Aggregate to document level
        sum_actual = actual.sum().item()
        sum_mean = mean_per_pos.sum().item()
        sum_std = var_per_pos.sum().sqrt().item()

        z_score = (sum_actual - sum_mean) / sum_std if sum_std > 0 else 0.0

        avg_log_prob = actual.mean().item()
        ppl = float(torch.exp(-actual.mean()).item())

        warning = None
        if n_tokens - 1 < self.SHORT_TEXT_THRESHOLD:
            warning = (
                f"Text has only {n_tokens - 1} scored tokens; results under "
                f"{self.SHORT_TEXT_THRESHOLD} tokens are unreliable."
            )

        return DetectionResult(
            z_score=z_score,
            avg_log_prob=avg_log_prob,
            perplexity=ppl,
            n_tokens=n_tokens - 1,
            model=self.model_name,
            verdict=_verdict_from_z(z_score),
            warning=warning,
        )
