#!/usr/bin/env python3
"""log_top.py - Print the top N IP addresses from a web access log."""
from collections.abc import Iterable
import sys


def parse_ip(line: str) -> str | None:
    """Return the first field if it is a valid IPv4 address, else None."""
    fields = line.split()
    if not fields:
        return None

    candidate = fields[0]
    parts = candidate.split(".")
    if len(parts) != 4:
        return None

    for part in parts:
        if not part.isdigit():
            return None
        num = int(part)
        if num < 0 or num > 255:
            return None

    return candidate


def count_ips(lines: Iterable[str]) -> dict[str, int]:
    """Count occurrences of each valid IP across an iterable of log lines."""
    counts: dict[str, int] = {}
    for line in lines:
        ip = parse_ip(line)
        if ip is not None:
            counts[ip] = counts.get(ip, 0) + 1
    return counts


def top_n(counts: dict[str, int], n: int = 10) -> list[tuple[str, int]]:
    """Return top n (ip, count) pairs sorted by count descending, then IP ascending."""
    # -item puts higher counts first; item breaks ties alphabetically
    sorted_items = sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    return sorted_items[:n]


def main(argv: list[str]) -> int:
    """CLI entrypoint: returns 0 on success, 1 if file missing, 2 if no args."""
    if not argv:
        print("Usage: log_top.py <logfile>", file=sys.stderr)
        return 2

    filepath = argv[0]
    try:
        with open(filepath, "r", encoding="utf-8") as fh:
            counts = count_ips(fh)
    except OSError as exc:
        print(f"Error: cannot open {filepath}: {exc.strerror}", file=sys.stderr)
        return 1

    for ip, count in top_n(counts):
        print(f"{ip} {count}")

    return 0


if __name__ == "__main__":
    # sys.argv skips the script name itself and passes only user arguments
    sys.exit(main(sys.argv[1:]))
