# Protocol Buffers Type Checking Experiment

## Simple mypy experiment

A simple mypy experiment can be found under the `python/foobarbaz`
folder.

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
mypy services_client.py
```

Nothing is detected.

TODO: try with flags

```
--strict --show-error-context --pretty --no-incremental
```

#### pysonar

Seems too complicated to install.

#### pyflakes

Install with

```
pip install pyflakes
```

Run

```
pyflakes type_checking_test.py
```

Nothing is detected.

#### pytype

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

#### pyre

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

#### pyright

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

#### pychecker

Unmaintained.

#### Conclusion

It seems that we can only type check type-annotated code.  By default
the Python code generated via protoc is not annotated, which is why it
does not work.  It seems however there are a few projects trying to
remedy that, such as

* https://github.com/nipunn1313/mypy-protobuf
* https://github.com/danielgtaylor/python-betterproto
* https://pypi.org/project/grpc-protoc-annotations/

It looks like protoc 3.20.0 supports
[https://peps.python.org/pep-0484/#stub-files](stub-files), see the
following
[https://github.com/protocolbuffers/protobuf/issues/2638#issuecomment-1106725624](issue).
However upgrading protoc (or rather grpcio-tools) and using the
`--pyi_out=` flag did not fix type checking.
