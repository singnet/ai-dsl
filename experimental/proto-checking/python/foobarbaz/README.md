# Simple mypy experiment

This is a simple mypy experiment involving stubs (files with the pyi
extension), to understand how to use mypy with these.

## Description

This folder contains 3 files

* `foobarbaz.py`: implements 3 functions, `foo`, `bar` and `baz`.
* `foobarbaz.pyi`: contains the type annotations of these 3 functions.
* `main.py`: compose these 3 functions, first a valid way, then in an
  invalid way.  The goal is to have mypy detect the invalid way.

## Prerequisites

Make sure mypy is installed

```
pip install mypy
```

## Usage

Call mypy on `main.py`

```
mypy main.py
```

which should output the following errors

```
main.py:9: error: Argument 1 to "baz" has incompatible type "int"; expected "str"  [arg-type]
main.py:9: error: Argument 1 to "foo" has incompatible type "str"; expected "bool"  [arg-type]
```

indicating that the type annotations are properly taken into account.

Deleting foobarbaz.pyi and recalling mypy on `main.py` outputs

```
Success: no issues found in 1 source file
```

indicating that mypy indeed uses type annotations from the stub file
when present.

