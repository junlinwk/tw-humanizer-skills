"""fast-detectgpt CLI.

The `check` subcommand uses stdlib only and works without torch/transformers
installed. The `score` subcommand requires the heavy deps and will print a
clear install hint if they are missing.

Usage:
    python -m detector.cli check
    python -m detector.cli score <file_or_->
    python -m detector.cli score text.txt --model Qwen/Qwen2.5-1.5B
    echo "some text" | python -m detector.cli score -
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from . import check_install


LANG_DEFAULTS = {
    "auto": "Qwen/Qwen2.5-1.5B",
    "zh": "Qwen/Qwen2.5-1.5B",
    "en": "Qwen/Qwen2.5-1.5B",
}


def _read_input(source: str) -> str:
    if source == "-":
        return sys.stdin.read()
    return Path(source).read_text(encoding="utf-8")


def _print_install_hint(status: dict) -> None:
    missing = [name for name, ok in status["deps"].items() if not ok]
    msg = {
        "error": "missing_dependencies",
        "missing": missing,
        "install_cmd": status["install_cmd"],
        "hint": (
            "The scorer needs torch and transformers (~3GB download for the "
            "default Qwen2.5-1.5B model on first run). These are NOT installed "
            "by default. Ask the user whether to install before running pip."
        ),
    }
    print(json.dumps(msg, ensure_ascii=False, indent=2), file=sys.stderr)


def cmd_check(args: argparse.Namespace) -> int:
    """Report whether heavy deps are installed."""
    status = check_install()
    print(json.dumps(status, ensure_ascii=False, indent=2))
    return 0 if status["ready"] else 1


def cmd_score(args: argparse.Namespace) -> int:
    status = check_install()
    if not status["ready"]:
        _print_install_hint(status)
        return 2

    # Deferred import — only loaded once we know deps are present.
    from .fast_detectgpt import FastDetectGPT

    text = _read_input(args.input)
    model = args.model or LANG_DEFAULTS.get(args.lang, LANG_DEFAULTS["auto"])

    detector = FastDetectGPT(model_name=model, device=args.device)
    result = detector.score(text, max_tokens=args.max_tokens)

    print(json.dumps(result.to_dict(), ensure_ascii=False, indent=2))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="fast-detectgpt",
        description="Fast-DetectGPT analytical scorer (Phase 1: score only).",
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_check = sub.add_parser(
        "check",
        help="Report whether heavy dependencies are installed",
    )
    p_check.set_defaults(func=cmd_check)

    p_score = sub.add_parser("score", help="Score a text file")
    p_score.add_argument(
        "input",
        help="Path to text file, or '-' to read from stdin",
    )
    p_score.add_argument(
        "--model",
        default=None,
        help="HuggingFace model id (overrides --lang default)",
    )
    p_score.add_argument(
        "--lang",
        default="auto",
        choices=list(LANG_DEFAULTS.keys()),
        help="Language hint for selecting default scoring model",
    )
    p_score.add_argument(
        "--device",
        default=None,
        help="cuda or cpu (default: cuda if available, else cpu)",
    )
    p_score.add_argument(
        "--max-tokens",
        type=int,
        default=2048,
        help="Truncate input to this many tokens (default: 2048)",
    )
    p_score.set_defaults(func=cmd_score)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
