#!/bin/bash

####################################################################
# Encode/decode prime number message but using NumberPrimalitySwap #
# instead of NumberPrimalitySwap.                                  #
####################################################################

# Encode prime message
echo "* Encode prime number message (swapped):"
cat prime_swap.msg
cat prime_swap.msg | protoc --encode=structured.SenderSwap sender_swap.proto > prime_swap.msg.encoded

# Print encoded message
echo
echo "* Encoded prime message in Wire format (swapped):"
cat prime_swap.msg.encoded
echo
echo
echo "* Encoded prime message in Hexadecimal format (swapped):"
hexdump prime_swap.msg.encoded
echo
echo "* Encoded prime message in Protoscope format (swapped):"
protoscope -explicit-length-prefixes -explicit-wire-types prime_swap.msg.encoded

# Decode raw message
echo
echo "* Decode prime message without using protobuf spec (swapped):"
cat prime_swap.msg.encoded | protoc --decode_raw

# Decode message with full protobuf spec
echo
echo "* Decode prime message using the full protobuf spec (swapped):"
cat prime_swap.msg.encoded | protoc --decode=structured.SenderSwap sender_swap.proto

# Decode message with partial protobuf spec (NumberPrimarily is
# replaced by Number)
echo
echo "* Decode prime message using partial protobuf spec (NumberPrimarily ↦ Number) (swapped):"
cat prime_swap.msg.encoded | protoc --decode=structured.NumberReceiverSwap receiver_number_swap.proto

# Decode message with very partial protobuf spec (NumberPrimarily is
# replaced by int64)
echo
echo "* Decode prime message using partial protobuf spec (NumberPrimarily ↦ int64) (swapped):"
cat prime_swap.msg.encoded | protoc --decode=structured.IntReceiver receiver_int.proto
