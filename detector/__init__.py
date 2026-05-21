"""tw-humanizer detector — Fast-DetectGPT scoring (Phase 1).

Heavy dependencies (torch, transformers) are NOT imported on package import,
so this module is safe to load even when the deps aren't installed. The
FastDetectGPT class is loaded lazily via __getattr__.
"""

from __future__ import annotations

from importlib import util as _import_util

__version__ = "0.1.0"
__all__ = ["FastDetectGPT", "DetectionResult", "check_install"]


def check_install() -> dict:
    """Return install status of optional heavy dependencies.

    Pure stdlib — safe to call without torch/transformers installed.
    """
    deps = {
        "torch": _import_util.find_spec("torch") is not None,
        "transformers": _import_util.find_spec("transformers") is not None,
    }
    return {
        "ready": all(deps.values()),
        "deps": deps,
        "install_cmd": "pip install torch transformers",
    }


def __getattr__(name: str):
    if name in ("FastDetectGPT", "DetectionResult"):
        from .fast_detectgpt import FastDetectGPT, DetectionResult
        return {"FastDetectGPT": FastDetectGPT, "DetectionResult": DetectionResult}[name]
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
