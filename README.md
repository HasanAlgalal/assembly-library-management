# Library Management System in x86 Assembly

A menu-driven educational library system written in **32-bit x86 assembly with NASM**, using Linux system calls directly for terminal input, output and exit.

Published by **Hasan Ahmed Yahya Algalal** as a systems programming project. The supplied source identifies the module as CT073-3-2 Computer System Low Level Techniques.

## Features

- Browse ten predefined books with titles, authors and availability.
- Search, borrow and return books by ID (1–10).
- Reject duplicate borrowing and returns of available books.
- Show borrowed-book counts and chronological borrow/return history.
- Validate complete numeric input and safely drain oversized lines.
- Keep a bounded log of 100 successful transactions.

## Build and run

Use an **x86 Linux environment**, including Ubuntu in WSL on Windows. This program is not a Windows executable. A 64-bit Linux host needs support for 32-bit x86 executables.

```bash
sudo apt-get update
sudo apt-get install nasm binutils make python3
git clone https://github.com/HasanAlgalal/assembly-library-management.git
cd assembly-library-management
make
./build/library
```

No C runtime, database, GUI toolkit or external application libraries are required.

```text
===== LIBRARY MANAGEMENT SYSTEM =====
1. View All Books
2. Search for a Book
3. Borrow a Book
4. Return a Book
5. View Statistics
6. Exit
Enter your choice:
```

Enter a menu number, then a book ID when prompted. Press Enter at the continuation prompt. Select 6 to exit; end-of-input also exits cleanly.

## Tests

```bash
make test
```

The tests execute the built Linux binary with scripted input. They cover the complete ten-book catalogue, book ID 10, borrowing/returning, statistics, invalid and oversized input, EOF, CRLF input and log exhaustion. GitHub Actions assembles, links and runs the tests on Ubuntu.

Local validation on Windows used NASM-generated machine code in a Unicorn x86 emulator with simulated Linux read/write/exit calls. Native Linux validation is performed by the repository's workflow; emulation alone does not verify Linux kernel integration.

## Design and limits

The code uses registers, conditional branches, reusable subroutines, byte arrays, manual decimal conversion and Linux `int 0x80` calls. Books and transaction records live in memory for one session.

- The catalogue is fixed at ten books; no editing or file persistence is implemented.
- There are no accounts or borrower identities. Availability belongs to the session.
- Once the log reaches 100 entries, further borrow/return changes are rejected. Restarting resets all state.
- Input must contain only decimal digits; blanks, spaces and mixed text are rejected. CRLF is accepted.
- This is a learning project, not a production library service.

The [original assignment flowchart](docs/original-flowchart.png) illustrates the initial menu and transaction flow. The maintained source adds EOF handling, complete input validation and a capacity guard that are not represented in that original diagram.

## Maintenance changes

The publication version fixes single-character ID parsing, unchecked log writes, incomplete-line input and EOF loops. It also replaces the misleading “borrowed by you” message with a status-based message. The original supplied file remains unchanged on the author's laptop.

## Repository layout

```text
library.asm                  Assembly source
Makefile                     Linux build and test commands
tests/test_cli.py            Executable regression tests
docs/original-flowchart.png  Original design reference
.github/workflows/verify.yml Native Linux verification
```
