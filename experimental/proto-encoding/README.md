# Protocol Buffers Encoding Decoding Experiment

## Description

Experiments to understand how protobuf encoding/decoding works.  More
specifically how consistent it is with some notion of subtyping.

## Prerequisites

- protoc
- protoscope

## Usage

Experiments are organized into the following folders:

- `basic`: experiments to acquire basic understanding of encoding and
  decoding.
- `primitive`: experiments to understand notions of subtyping over
  primitive types.
- `structured`: experiments to understand notions of subtyping over
  structured types.

## Conclusion

The behavior of protobuf is compatible with a notion of subtyping.
Structed types can be specialized via *width subtyping* (adding more
fields), *depth subtyping* (specializing existing fields) or a
combination thereof.  Behaviorally speaking, coercion from structured
subtypes to supertypes is implicit, because protobuf spontaneously
decodes data encoded with subtypes into data consistent with
supertypes.

There is also a notion of subtyping between primitive types that
emerges from the wire/protoscope format.  For instance data of types
`bool` and `int32` both get encoded as type `VARINT` in protoscope
format.  Therefore data of type `bool` can be implicit coerced to be
of type `int32` without any loss.  Therefore `bool` can be seen as a
subtype of `int32`.  Such implicit coercion also works the other way
around but leads to data loss, thus must be avoided by the type
system.

Such notion of subtyping does not however incorporate implicit
coercion between stuctured and primitive types.  This has the
advantage to make subtyping less ambiguous.  But has the inconvenience
that a service expecting to receive a primitive type cannot receive a
structured type instead.

For instance a service that expects data typed as

```
message Msg {
  string video_url = 1
}
```

cannot receive instead data typed as

```
message Msg {
  URL video = 1
}
```

where `URL` would be a structured type like

```
message URL {
  string url = 1
}
```

eventhough the field of interest is of type `string` in both cases.

To remedy that an explicit coercion mechanism must be used.  Such
mechanism would likely take the form of a middleware implementing
casting functions inserted between senders and receivers, when needed.

Something that has been left aside are the notion of subtyping between
functions, or Remote Procedure Calls (RPC) in the context of protobuf.
However such subtyping should be entirely derivable from the subtyping
between data types via the input-contravariant output-covariant rule.
