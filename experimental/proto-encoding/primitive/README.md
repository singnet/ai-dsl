# Encoding/Decoding over Primitive Types

## Description

Experiment with encoding and decoding over primitive types in order to
understand how implicit coercion may work between types.  In
particular we want to know if such coercion is lossy or not.

## Usage

Run the script `primitive.sh`.

## Conclusion

The following message

```
float_val: 0.42
double_val: 0.42
int32_val: 42
sint32_val: -42
sfixed32_val: -42
int64_val: 42
sint64_val: -42
sfixed64_val: -42
uint32_val: 42
fixed32_val: 42
uint64_val: 42
fixed64_val: 42
string_val: "forty two"
bytes_val: "forty two"
bool_val: true
```

is encoded, then decoded by the receiver.  Let us recall the protobuf
specification of the receiver.

```
message Receiver {
  double float_to_double = 1;
  float double_to_float = 2;
  sint32 int32_to_sint32 = 3;
  int32 sint32_to_int32 = 4;
  sfixed64 sfixed32_to_sfixed64 = 5;
  sint64 int64_to_sint64 = 6;
  int64 sint64_to_int64 = 7;
  sfixed32 sfixed64_to_sfixed32 = 8;
  fixed32 uint32_to_fixed32 = 9;
  uint32 fixed32_to_uint32 = 10;
  uint32 uint64_to_uint32 = 11;
  bool fixed64_to_bool = 12;
  bytes string_to_bytes = 13;
  string bytes_to_string = 14;
  int32 bool_to_int32 = 15;
}
```

The result from the receiver is the following (the results have been
sorted to match the specification)

```
1: 0x3ed70a3d
2: 0x3fdae147ae147ae1
int32_to_sint32: 21
sint32_to_int32: 83
5: 0xffffffd6
int64_to_sint64: 21
sint64_to_int64: 83
8: 0xffffffffffffffd6
9: 42
10: 0x0000002a
uint64_to_uint32: 42
12: 0x000000000000002a
string_to_bytes: "forty two"
bytes_to_string: "forty two"
bool_to_int32: 1
```

The first observation is that protoc could not coerce `double` from/to
`float`.  That probably has to do with the fact that `float` and
`double` are turned into `I32` and `I64` respectively, two different
protoscope types.

Coercing `int32` to `sint32` failed, the value changed in the process,
going from `42` to `21`, even though they are both represented by the
same underlying protoscope type, `VARINT`.  A similar problem occurred
for the coercion of `sint32` to `int32`, `int64` to `sint64` and
`sint64` to `int64`.

The coercion of `sfixed32` to/from `sfixed64` failed as well, likely
because they have different protoscope types, `I32` and `I64`.

The coercion of `uint32` to `fixed32` succeeded, eventhough they have
different protoscope types, `VARINT` and `I32`.  This could be a lucky
accident and should be investigated further.  The other way around,
`fixed32` to `uint32` succeeded as well, as indeed `0x0000002a`
corresponds to `42`.

The coercion of `uint64` to `uint32` succeeded but that is because
`42` is small enough to fit inside both types.  The other way around
would likely always succeed, and thus it can likely be assumed that
`uint32` is a subtype of `uint64`.

It is fair to say that `fixed64` to `bool` failed since such mapping
is lossy.  The coersion from `bool` to `int32` succeeded.  That is
because they both use the same underlying protoscope type `VARINT` and
such mapping is not lossy.

Coercing `string` from/to `bytes` worked.  Both have the same
underlying protoscope type `LEN`.  The only reason they are different
protobuf types is because `string` is only supposed to take bytes
representing characters.  Therefore it is certain that `string` is a
subtype of `bytes`.  Whether `bytes` is a subtype of `string` may
depend on the host language.  In our experiment we could only enter
bytes that are characters so we cannot conclude.

Based on that experiment, let us list below the subtyping
relationships, `<:`.  We expect the following to hold

```
bool <: int32
int32 <: int64
uint32 <: uint64
suint32 <: suint64
string <: bytes
```

More are certainly possible, alongside all of those that can be
derived via transitivity, etc.  Finally, let us restate that this is
an expectation.  To be absolutely sure, more experiments, as well as
possibly reviewing the protoc code, should be conducted to confirm it.
