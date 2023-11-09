#!/bin/bash

#####################################
# Encode/decode even number message #
#####################################

# Encode even message
echo "* Encode even number message:"
cat even.msg
protoc --encode=structured.Sender sender.proto < even.msg > even.msg.encoded

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
echo
echo "* Encoded even message in protobuf-inspector format:"
protobuf_inspector < even.msg.encoded

# Decode raw message
echo
echo "* Decode even message without using protobuf spec:"
protoc --decode_raw < even.msg.encoded

# Decode message with full protobuf spec
echo
echo "* Decode even message using the full protobuf spec:"
protoc --decode=structured.Sender sender.proto < even.msg.encoded

# Decode message with partial protobuf spec (NumberPrimarily is
# replaced by Number)
echo
echo "* Decode even message using partial protobuf spec (NumberPrimarily ↦ Number):"
protoc --decode=structured.NumberReceiver receiver_number.proto < even.msg.encoded

# Decode message with very partial protobuf spec (NumberPrimarily is
# replaced by int64)
echo
echo "* Decode even message using partial protobuf spec (NumberPrimarily ↦ int64):"
protoc --decode=structured.IntReceiver receiver_int.proto < even.msg.encoded
