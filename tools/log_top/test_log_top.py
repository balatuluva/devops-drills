from log_top import count_ips, main, parse_ip, top_n


def test_parse_ip_valid_line():
    line = '10.0.0.4 - - [21/Nov/2026:07:00:00] "GET /item/0 HTTP/1.1" 200 512'
    assert parse_ip(line) == "10.0.0.4"


def test_parse_ip_blank_line_returns_none():
    assert parse_ip("") is None
    assert parse_ip("   \n") is None


def test_parse_ip_rejects_octet_over_255():
    assert parse_ip("10.0.0.256 - -") is None
    assert parse_ip("999.1.1.1 - -") is None


def test_count_ips_counts_repeats():
    lines = [
        "10.0.0.1 - - GET /",
        "10.0.0.2 - - GET /",
        "10.0.0.1 - - GET /",
        "",  # blank line should be ignored
    ]
    assert count_ips(lines) == {"10.0.0.1": 2, "10.0.0.2": 1}


def test_top_n_orders_by_count_then_ip():
    counts = {
        "10.0.0.3": 5,
        "10.0.0.1": 5,
        "10.0.0.2": 10,
    }
    # 10.0.0.2 wins (10), then 10.0.0.1 beats 10.0.0.3 on tie-break
    assert top_n(counts, n=3) == [
        ("10.0.0.2", 10),
        ("10.0.0.1", 5),
        ("10.0.0.3", 5),
    ]


def test_top_n_handles_n_larger_than_unique():
    counts = {"10.0.0.1": 3, "10.0.0.2": 1}
    result = top_n(counts, n=10)
    assert len(result) == 2
    assert result == [("10.0.0.1", 3), ("10.0.0.2", 1)]


def test_main_no_args_returns_2():
    assert main([]) == 2


def test_main_missing_file_returns_1(capsys):
    code = main(["does_not_exist.log"])
    captured = capsys.readouterr()
    assert code == 1
    assert "cannot open" in captured.err
