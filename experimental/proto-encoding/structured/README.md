# Encoding/Decoding over Structured Types

## Description

Experiment with more advanced situations of encoding and decoding,
especially regarding structured types, as well as their interactions
with primitive types.

## Usage

- `prime.sh`: encode a message with a prime number and a field
  indicating its primality.  Then decode using the full protobuf
  specification, a partial one when the primality has been stripped,
  and a very partial one where the whole primality number message type
  has been replaced by a mere integer.
- `even.sh`: same experiment as `prime.sh` but an even number is sent
  instead.
- `prime-swap.sh`: same experiment as `prime.sh` but the order of in
  the NumberPrimality message structure has been swapped.

## Conclusion

Protobuf is able to handle decoding partially specified messages.
However, a field of a structured type is not automaticaly coerced to a
field of a primitive type.  Instead the receiver keeps the structure
of the sender, as encoded by the Wire format.
