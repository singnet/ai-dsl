#!/bin/bash

#####################################
# Encode/decode even number message #
#####################################

# Encode even message
echo "* Encode even number message:"
cat even.msg
cat even.msg | protoc --encode=structured.Sender sender.proto > even.msg.encoded

# Print encoded message
echo
echo "* Encoded even message in Wire format:"
cat even.msg.encoded
echo
echo
echo "* Encoded even message in Hexadecimal format:"
hexdump even.msg.encoded
echo
echo "* Encoded even message in Protoscope format:"
protoscope -explicit-length-prefixes -explicit-wire-types even.msg.encoded

# Decode raw message
echo
echo "* Decode even message without using protobuf spec:"
cat even.msg.encoded | protoc --decode_raw

# Decode message with full protobuf spec
echo
echo "* Decode even message using the full protobuf spec:"
cat even.msg.encoded | protoc --decode=structured.Sender sender.proto

# Decode message with partial protobuf spec (NumberPrimarily is
# replaced by Number)
echo
echo "* Decode even message using partial protobuf spec (NumberPrimarily ↦ Number):"
cat even.msg.encoded | protoc --decode=structured.NumberReceiver receiver_number.proto

# Decode message with very partial protobuf spec (NumberPrimarily is
# replaced by int64)
echo
echo "* Decode even message using partial protobuf spec (NumberPrimarily ↦ int64):"
cat even.msg.encoded | protoc --decode=structured.IntReceiver receiver_int.proto
