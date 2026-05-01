#!/usr/bin/env python3
"""Genera lib/l10n/app_es.arb y app_en.arb desde tools/l10n.jsonl (una línea JSON por clave)."""
import json
from pathlib import Path

root = Path(__file__).resolve().parent
lines = (root / "l10n.jsonl").read_text(encoding="utf-8").splitlines()
es = {"@@locale": "es"}
en = {"@@locale": "en"}
for line in lines:
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    o = json.loads(line)
    k = o["key"]
    es[k] = o["es"]
    en[k] = o["en"]

out = Path(__file__).resolve().parent.parent / "lib" / "l10n"
out.mkdir(parents=True, exist_ok=True)
(out / "app_es.arb").write_text(
    json.dumps(es, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
(out / "app_en.arb").write_text(
    json.dumps(en, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print("Wrote", len(es) - 1, "keys")
