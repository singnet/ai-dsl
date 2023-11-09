#!/bin/bash

######################################
# Encode/decode prime number message #
######################################

# Encode prime message
echo "* Encode prime number message:"
cat prime.msg
protoc --encode=structured.Sender sender.proto < prime.msg > prime.msg.encoded

# Print encoded message
echo
echo "* Encoded prime message in Wire format:"
cat prime.msg.encoded
echo
echo
echo "* Encoded prime message in Hexadecimal format:"
hexdump prime.msg.encoded
echo
echo "* Encoded prime message in Protoscope format:"
protoscope -explicit-length-prefixes -explicit-wire-types prime.msg.encoded
echo
echo "* Encoded prime message in protobuf-inspector format:"
protobuf_inspector < prime.msg.encoded

# Decode raw message
echo
echo "* Decode prime message without using protobuf spec:"
protoc --decode_raw < prime.msg.encoded

# Decode message with full protobuf spec
echo
echo "* Decode prime message using the full protobuf spec:"
protoc --decode=structured.Sender sender.proto < prime.msg.encoded

# Decode message with partial protobuf spec (NumberPrimarily is
# replaced by Number)
echo
echo "* Decode prime message using partial protobuf spec (NumberPrimarily ↦ Number):"
protoc --decode=structured.NumberReceiver receiver_number.proto < prime.msg.encoded

# Decode message with very partial protobuf spec (NumberPrimarily is
# replaced by int64)
echo
echo "* Decode prime message using partial protobuf spec (NumberPrimarily ↦ int64):"
protoc --decode=structured.IntReceiver receiver_int.proto < prime.msg.encoded
