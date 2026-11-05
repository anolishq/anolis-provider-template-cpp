#!/usr/bin/env python3
"""Run the anolis-protocol conformance harness against the provider.

    scripts/conformance.py <provider binary> [harness executable]

Passes only with no failures, and no skips beyond EXPECTED_SKIPS. Without a
harness argument it uses anolis-adpp-conformance from PATH.
"""

from __future__ import annotations

import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]

# A skip not listed here fails the run. List one only with the reason the
# harness cannot exercise it on this provider.
EXPECTED_SKIPS = {
    "test_l2_expired_deadline_exceeded": "the C++ SDK does not support call deadlines yet (anolis-provider-sdk#71)",
    "test_l2_malformed_deadline_is_invalid_argument": "the C++ SDK does not support call deadlines yet (anolis-provider-sdk#71)",
}


def main() -> int:
    if len(sys.argv) not in (2, 3):
        print(__doc__, file=sys.stderr)
        return 2
    provider = str(Path(sys.argv[1]).resolve())
    harness = sys.argv[2] if len(sys.argv) == 3 else "anolis-adpp-conformance"
    with tempfile.TemporaryDirectory() as tmp:
        report = Path(tmp) / "report.xml"
        proc = subprocess.run(
            [
                harness,
                "--provider-bin",
                provider,
                "--provider-config",
                str(REPO / "config" / "conformance.yaml"),
                "--provider-profile",
                str(REPO / "config" / "conformance.toml"),
                f"--junitxml={report}",
                "-p",
                "no:cacheprovider",
                "-ra",
            ],
            cwd=tmp,
        )
        cases = list(ET.parse(report).iter("testcase"))
    failed = [c.get("name") for c in cases if c.find("failure") is not None or c.find("error") is not None]
    skipped = {c.get("name") for c in cases if c.find("skipped") is not None}
    unexpected = sorted(skipped - EXPECTED_SKIPS.keys())
    passed = len(cases) - len(skipped) - len(failed)
    print(f"harness against {provider}: {passed} passed, {len(skipped)} skipped, {len(failed)} failed")
    if proc.returncode != 0 or failed:
        print(f"failed: {failed}", file=sys.stderr)
        return 1
    if unexpected:
        print(f"unexpected skips: {unexpected}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
