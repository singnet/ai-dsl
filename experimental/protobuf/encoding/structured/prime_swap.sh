#!/bin/bash

####################################################################
# Encode/decode prime number message but using NumberPrimalitySwap #
# instead of NumberPrimalitySwap.                                  #
####################################################################

# Encode prime message
echo "* Encode prime number message (swapped):"
cat prime_swap.msg
protoc --encode=structured.SenderSwap sender_swap.proto < prime_swap.msg > prime_swap.msg.encoded

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
echo
echo "* Encoded prime message in protobuf-inspector format (swapped):"
protobuf_inspector < prime_swap.msg.encoded

# Decode raw message
echo
echo "* Decode prime message without using protobuf spec (swapped):"
protoc --decode_raw < prime_swap.msg.encoded

# Decode message with full protobuf spec
echo
echo "* Decode prime message using the full protobuf spec (swapped):"
protoc --decode=structured.SenderSwap sender_swap.proto < prime_swap.msg.encoded

# Decode message with partial protobuf spec (NumberPrimarily is
# replaced by Number)
echo
echo "* Decode prime message using partial protobuf spec (NumberPrimarily ↦ Number) (swapped):"
protoc --decode=structured.NumberReceiverSwap receiver_number_swap.proto < prime_swap.msg.encoded

# Decode message with very partial protobuf spec (NumberPrimarily is
# replaced by int64)
echo
echo "* Decode prime message using partial protobuf spec (NumberPrimarily ↦ int64) (swapped):"
protoc --decode=structured.IntReceiver receiver_int.proto < prime_swap.msg.encoded
