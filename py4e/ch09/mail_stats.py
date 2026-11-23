def read_lines(path: str) -> list[str]:
    with open(path, "r", encoding="utf-8") as f:
        return f.readlines()


def day_counts(lines: list[str]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for line in lines:
        if line.startswith("From "):
            words = line.split()
            if len(words) >= 3:
                day = words[2]
                counts[day] = counts.get(day, 0) + 1
    return counts


def sender_counts(lines: list[str]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for line in lines:
        if line.startswith("From "):
            words = line.split()
            if len(words) >= 2:
                sender = words[1]
                counts[sender] = counts.get(sender, 0) + 1
    return counts


def top_sender(counts: dict[str, int]) -> tuple[str, int]:
    if not counts:
        raise ValueError("counts dictionary is empty")
    max_sender = ""
    max_count = -1
    for sender, count in counts.items():
        if count > max_count:
            max_sender = sender
            max_count = count
    return (max_sender, max_count)


def main() -> int:
    fname = input("Enter a file name: ")
    try:
        lines = read_lines(fname)
    except OSError:
        print(f"File cannot be opened: {fname}")
        return 1

    print(day_counts(lines))
    senders = sender_counts(lines)
    print(senders)
    if senders:
        person, count = top_sender(senders)
        print(person, count)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
