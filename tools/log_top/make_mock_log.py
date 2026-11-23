#!/usr/bin/env python3
"""make_mock_log.py - write a fake web access log (no real data)."""
import random
import sys

def make_line(i, rng):
    ip = f"10.0.0.{rng.randint(1, 8)}"
    code = rng.choice([200, 200, 200, 404, 500])
    return f'{ip} - - [21/Nov/2026:07:{i % 60:02d}:00] "GET /item/{i} HTTP/1.1" {code} 512'

def main(path, count=500, seed=42):
    rng = random.Random(seed)
    with open(path, "w") as fh:
        for i in range(count):
            fh.write(make_line(i, rng) + "\n")
    print(f"wrote {count} lines to {path}")

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "mock_access.log")
