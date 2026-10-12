"""Black-box regression checks against the actual Linux executable."""
import subprocess
import unittest
from pathlib import Path

BINARY = Path(__file__).resolve().parents[1] / 'build' / 'library'

def run(text):
    completed = subprocess.run([str(BINARY)], input=text, text=True,
                               capture_output=True, timeout=5)
    if completed.returncode != 0:
        raise AssertionError(f'Exit {completed.returncode}: {completed.stderr}')
    return completed.stdout

class LibraryTests(unittest.TestCase):
    def test_exit(self):
        self.assertIn('Goodbye!', run('6\n'))

    def test_catalogue(self):
        output = run('1\n\n6\n')
        for book in range(1, 11):
            self.assertIn(f'ID: {book} |', output)

    def test_search_ten(self):
        output = run('2\n10\n\n6\n')
        self.assertIn('ID: 10 | Title: Structure and Interpretation', output)
        self.assertNotIn('ID: 1 |', output)

    def test_borrow_return_ten(self):
        output = run('3\n10\n\n4\n10\n\n5\n\n6\n')
        self.assertIn('ID: 10 |', output)
        self.assertIn('Status: Borrowed', output)
        self.assertIn('Currently Borrowed: 0', output)
        self.assertIn('Total Transactions: 2', output)
        self.assertIn('Book ID: 10 was borrowed', output)
        self.assertIn('Book ID: 10 was returned', output)

    def test_duplicate_borrow(self):
        output = run('3\n1\n\n3\n1\n\n5\n\n6\n')
        self.assertIn('currently unavailable', output)
        self.assertIn('Total Transactions: 1', output)
        self.assertIn('Currently Borrowed: 1', output)

    def test_return_available(self):
        self.assertIn('not currently borrowed', run('4\n1\n\n6\n'))

    def test_invalid_menu(self):
        for value in ('0', '7', '10', '1abc', '', '-1', '9999999999'):
            with self.subTest(value=value):
                self.assertIn('Invalid choice', run(value + '\n\n6\n'))

    def test_invalid_id(self):
        for value in ('0', '11', '1abc', '', '-1', ' 1', '9999999999'):
            with self.subTest(value=value):
                self.assertIn('Invalid book ID', run('2\n' + value + '\n\n6\n'))

    def test_long_line_drained(self):
        output = run('2\n' + '1' * 100 + '\n\n6\n')
        self.assertEqual(output.count('Invalid book ID'), 1)
        self.assertIn('Goodbye!', output)

    def test_eof(self):
        for text in ('', '2\n', '3\n1\n', '6'):
            with self.subTest(text=text):
                self.assertIn('Goodbye!', run(text))

    def test_crlf(self):
        self.assertIn('ID: 10 |', run('2\r\n10\r\n\r\n6\r\n'))

    def test_full_log_preserves_state(self):
        commands = ''.join(('3\n' if i % 2 == 0 else '4\n') + '1\n\n' for i in range(100))
        output = run(commands + '3\n1\n\n5\n\n6\n')
        self.assertIn('Transaction log is full', output)
        self.assertIn('Total Transactions: 100', output)
        self.assertIn('Currently Borrowed: 0', output)
        self.assertEqual(output.count('Book ID: 1 was borrowed'), 50)
        self.assertEqual(output.count('Book ID: 1 was returned'), 50)

if __name__ == '__main__':
    unittest.main()
