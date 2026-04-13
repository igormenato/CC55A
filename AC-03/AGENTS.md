# Repository Guidelines

## Project Structure & Module Organization

This repository contains Flex-based lexical analyzers and their regression tests.

- `examples/`: the five example scanners from the assignment (`exemplo0.l` through `exemplo4.l`).
- `ids/`: the identifier analyzer, currently `c_identifiers.l`.
- `tests/`: input/output fixtures plus the test runner `run_tests.sh`.
- `build/`: generated C files produced by `flex`.
- `bin/`: compiled executables produced by `gcc`.

Keep generated files out of source changes unless the task explicitly requires them.

## Build, Test, and Development Commands

- `make`: runs `flex` and `gcc` to build all scanners into `bin/`.
- `make test`: rebuilds when needed and executes all test suites in `tests/`.
- `make clean`: removes generated artifacts from `build/` and `bin/`.

Example: run `make test` before opening a PR or handing in changes.

## Coding Style & Naming Conventions

Use C-style formatting inside `.l` files:

- 4-space indentation.
- `snake_case` for C helper functions and variables.
- descriptive uppercase names for Flex regex macros, such as `ID_VALIDO` or `DELIMITADOR`.

Prefer small helper functions in the `%{ ... %}` block when scanner actions would otherwise become repetitive. There is no formatter configured in this repository, so keep style consistent manually.

## Testing Guidelines

Tests are fixture-based. Each case uses:

- `tests/<suite>/<name>.in` for stdin input
- `tests/<suite>/<name>.out` for expected stdout

Add or update tests whenever scanner behavior changes, especially for edge cases such as punctuation boundaries, invalid identifiers, and missing trailing newlines. Name tests by behavior, for example `no_trailing_newline.in` or `punctuation_delimited.in`.

## Commit & Pull Request Guidelines

Use Conventional Commits for all commit messages, for example `feat: add fixture for unterminated line handling` or `fix: handle missing trailing newline`.

PRs should include:

- a short summary of what changed
- the reason for the change
- validation performed, usually `make test`
- commit history that remains readable and follows Conventional Commits
