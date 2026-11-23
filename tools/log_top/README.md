# log_top

A lightweight CLI utility to parse web server access logs and display the top 10 most frequent client IPv4 addresses.

## Usage

Generate a sample log file and inspect the top IPs:

```bash
python3 make_mock_log.py mock_access.log
python3 log_top.py mock_access.log
```

Run the automated test suite:

```bash
pytest
```
