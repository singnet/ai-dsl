#!/bin/bash

######################################
# Encode/decode prime number message #
######################################

# Encode prime message
echo "* Encode prime number message:"
cat prime.msg
cat prime.msg | protoc --encode=structured.Sender sender.proto > prime.msg.encoded

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

# Decode raw message
echo
echo "* Decode prime message without using protobuf spec:"
cat prime.msg.encoded | protoc --decode_raw

# Decode message with full protobuf spec
echo
echo "* Decode prime message using the full protobuf spec:"
cat prime.msg.encoded | protoc --decode=structured.Sender sender.proto

# Decode message with partial protobuf spec (NumberPrimarily is
# replaced by Number)
echo
echo "* Decode prime message using partial protobuf spec (NumberPrimarily ↦ Number):"
cat prime.msg.encoded | protoc --decode=structured.NumberReceiver receiver_number.proto

# Decode message with very partial protobuf spec (NumberPrimarily is
# replaced by int64)
echo
echo "* Decode prime message using partial protobuf spec (NumberPrimarily ↦ int64):"
cat prime.msg.encoded | protoc --decode=structured.IntReceiver receiver_int.proto
