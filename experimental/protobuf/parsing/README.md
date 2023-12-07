# Protobuf Parsing Experiment

## Description

Experiments to parse protobuf specifications and turn them into MeTTa.

## Prerequisites

- hyperon, https://github.com/trueagi-io/hyperon-experimental
- python (tested with Python 3.9.2)
- grpcio-tools (tested with 1.19.0)

## Usage

### Build protobuf specifications

First you need to compile the protobuf specifications, run the following script:

```
./build.sh
```

This will generate Python files under the `python` subfolder.  These
Python files contain Python specifications corresponding to the
protobuf specifications in the proto files.  We will be able to use
these Python structures to convert the protobuf specifications to
MeTTa.

### Parsing

There is a parsing test under the `python` subfolder that can be run:

```
python python/parsing_test.py
```

### Clean-up protobuf compiled files

If you wish to clean up the Python files generated during the building
process, run the following script:

```
./clean.sh
```
