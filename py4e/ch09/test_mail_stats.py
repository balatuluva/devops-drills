import unittest
from mail_stats import day_counts, sender_counts, top_sender


class TestMailStats(unittest.TestCase):
    def test_day_counts_counts_only_from_space_lines(self):
        lines = [
            "From a@example.com Sat Jan 5 09:14:16 2008\n",
            "From b@example.com Fri Jan 4 18:10:48 2008\n",
            "From c@example.com Sat Jan 5 10:00:00 2008\n",
            "Subject: Hello Sat\n",
        ]
        self.assertEqual(day_counts(lines), {"Sat": 2, "Fri": 1})

    def test_day_counts_ignores_from_colon_lines(self):
        lines = [
            "From: a@example.com Sat Jan 5 09:14:16 2008\n",
            "From b@example.com Fri Jan 4 18:10:48 2008\n",
        ]
        self.assertEqual(day_counts(lines), {"Fri": 1})

    def test_sender_counts_counts_repeat_sender(self):
        lines = [
            "From a@example.com Sat Jan 5 09:14:16 2008\n",
            "From a@example.com Fri Jan 4 18:10:48 2008\n",
            "From b@example.com Thu Jan 3 12:00:00 2008\n",
        ]
        self.assertEqual(
            sender_counts(lines),
            {"a@example.com": 2, "b@example.com": 1},
        )

    def test_top_sender_returns_highest_count(self):
        counts = {"a@example.com": 2, "b@example.com": 5, "c@example.com": 1}
        self.assertEqual(top_sender(counts), ("b@example.com", 5))

    def test_top_sender_empty_raises_value_error(self):
        with self.assertRaises(ValueError):
            top_sender({})


if __name__ == "__main__":
    unittest.main()
