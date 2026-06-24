#!/usr/bin/env python3
"""Search a decision-ledger index without loading full note bodies.

The index is expected to be JSON Lines. Each line should contain compact
metadata plus a `path` to the full note. This script intentionally searches the
index only, so agents can choose which small set of notes to open later.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

FIELD_WEIGHTS = {
    "id": 8,
    "status": 5,
    "project": 5,
    "scope": 6,
    "module": 8,
    "problem": 7,
    "symptoms": 7,
    "keywords": 9,
    "related_files": 9,
    "summary": 4,
    "path": 8,
}

STATUS_PRIORITY = {"experience": 4, "rejected": 3, "accepted": 2, "proposed": 1}


def flatten(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, (list, tuple, set)):
        return " ".join(flatten(item) for item in value)
    if isinstance(value, dict):
        return " ".join(f"{key} {flatten(val)}" for key, val in value.items())
    return str(value)


def normalize(text: str) -> str:
    return text.casefold().replace("\\", "/")


def query_terms(query: str) -> list[str]:
    raw = normalize(query)
    parts = [p for p in re.split(r"[\s,;，；、]+", raw) if p]
    # Keep the full query too; Chinese or path-like queries often work best as substrings.
    terms = []
    if raw.strip():
        terms.append(raw.strip())
    terms.extend(parts)
    seen: set[str] = set()
    deduped = []
    for term in terms:
        if term not in seen:
            deduped.append(term)
            seen.add(term)
    return deduped


def load_index(path: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_no, line in enumerate(handle, start=1):
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            try:
                record = json.loads(stripped)
            except json.JSONDecodeError as exc:
                print(f"warning: skip invalid JSON at {path}:{line_no}: {exc}", file=sys.stderr)
                continue
            if isinstance(record, dict):
                record.setdefault("_line", line_no)
                records.append(record)
    return records


def matches_filter(record: dict[str, Any], field: str, expected: str | None) -> bool:
    if not expected:
        return True
    actual = normalize(flatten(record.get(field, "")))
    return normalize(expected) in actual


def score_record(record: dict[str, Any], terms: list[str]) -> tuple[int, list[str]]:
    score = 0
    hits: list[str] = []
    for field, weight in FIELD_WEIGHTS.items():
        value = normalize(flatten(record.get(field, "")))
        if not value:
            continue
        for term in terms:
            if term and term in value:
                score += weight + min(len(term), 24) // 4
                hits.append(field)
    if not hits:
        return 0, []
    return score, sorted(set(hits))


def main() -> int:
    parser = argparse.ArgumentParser(description="Search a compact decision-ledger JSONL index.")
    parser.add_argument("--index", default="docs/decision-ledger/index.jsonl", help="Path to index.jsonl")
    parser.add_argument("--query", required=True, help="Search query")
    parser.add_argument("--project", help="Project metadata filter")
    parser.add_argument("--scope", help="Scope metadata filter")
    parser.add_argument("--module", help="Module metadata filter")
    parser.add_argument("--status", choices=["proposed", "accepted", "rejected", "experience"], help="Status filter")
    parser.add_argument("--top", type=int, default=5, help="Number of matches to print")
    parser.add_argument("--json", action="store_true", help="Print JSON lines")
    args = parser.parse_args()

    index_path = Path(args.index)
    if not index_path.exists():
        print(f"index not found: {index_path}", file=sys.stderr)
        print("create docs/decision-ledger/index.jsonl or pass --index", file=sys.stderr)
        return 2

    terms = query_terms(args.query)
    records = load_index(index_path)
    ranked: list[tuple[int, list[str], dict[str, Any]]] = []
    for record in records:
        if not matches_filter(record, "project", args.project):
            continue
        if not matches_filter(record, "scope", args.scope):
            continue
        if not matches_filter(record, "module", args.module):
            continue
        if args.status and normalize(flatten(record.get("status"))) != args.status:
            continue
        score, hits = score_record(record, terms)
        if score > 0:
            ranked.append((score, hits, record))

    ranked.sort(key=lambda item: (STATUS_PRIORITY.get(normalize(flatten(item[2].get("status"))), 0), item[0]), reverse=True)
    if not ranked:
        if not args.json:
            print("no matches")
        return 0
    for score, hits, record in ranked[: max(args.top, 0)]:
        result = {
            "score": score,
            "hits": hits,
            "id": record.get("id"),
            "status": record.get("status"),
            "scope": record.get("scope"),
            "module": record.get("module"),
            "problem": record.get("problem"),
            "summary": record.get("summary"),
            "path": record.get("path"),
        }
        if args.json:
            print(json.dumps(result, ensure_ascii=False))
        else:
            print(f"score={score} status={result['status']} id={result['id']}")
            print(f"  problem: {result['problem']}")
            if result.get("summary"):
                print(f"  summary: {result['summary']}")
            print(f"  path: {result['path']}")
            print(f"  hits: {', '.join(hits)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


