# Protocol Buffers Type Checking Experiment

## Prerequisites

- python (tested with Python 3.9.2)
- grpcio-tools (tested with 52.0.0).  It's important that grpcio-tools
  be sufficiently recent to support type-annotations (then
  `--pyi_out=` flag can be used).

## Build protobuf specifications

```
./build.sh
```

## Clean-up protobuf compiled files

```
./clean.sh
```

## Type Check Compositions

### Python

Go under the `python` folder and follow the instructions below.

#### mypy

Install with

```
pip install mypy
```

Then run

```
mypy --check-untyped-defs services_client_invalid_composition.py
```

which should output

```
services_client_invalid_composition.py:22: error: Argument "foo_bool" to "FooIn" has incompatible type "str"; expected "bool"  [arg-type]
services_client_invalid_composition.py:27: error: Argument "baz_str" to "BazIn" has incompatible type "int"; expected "Optional[str]"  [arg-type]
```

meaning that mypy has managed to detect that the composition was
invalid.

Note that there is an even simpler mypy experiment under the
`foobarbaz` folder.

#### Conclusion

By compiling protobuf into Python annotated code, which recent
versions of grpcio-tools seems to be able to do, and annotating
compositions, then mypy is able to type check compositions.

In addition to mypy we have attempted other Python checkers.  Our
findings is documented below.  The take away seems to be that none
offer anything better than mypy, and mypy seems to be the most
popular, thus the default choice.

#### Other Python Checkers

##### pysonar

Seems too complicated to install.

##### pyflakes

Install with

```
pip install pyflakes
```

Run

```
pyflakes type_checking_test.py
```

Nothing is detected.

##### pytype

Install with

```
pip install pytype
```

Run

```
pytype type_checking_test.py
```

Only invalid compositions using functions annotated with types are
detected.

##### pyre

Install with

```
pip install pyre-check
```

then initialize with

```
pyre init
```

and run with

```
pyre
```

It spures a lot of errors, including a lot of false positives (maybe
the initialization went wrong).

##### pyright

Install with

```
pip install pyright
```

Then run with

```
pyright type_checking_test.py
```

Only invalid compositions using functions annotated with types are
detected.

##### pychecker

Unmaintained.
