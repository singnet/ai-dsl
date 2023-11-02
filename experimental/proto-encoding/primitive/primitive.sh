#!/bin/bash

# Encode message
echo "* Encode the following protobuf message using the primitive spec:"
cat primitive.msg
cat primitive.msg | protoc --encode=primitive.Primitive primitive.proto > primitive.msg.encoded

# Print encoded message
echo
echo "* Encoded message in Wire format:"
cat primitive.msg.encoded
echo
echo
echo "* Encoded message in Hexadecimal format:"
hexdump primitive.msg.encoded
echo
echo "* Encoded message in Protoscope format:"
protoscope -explicit-length-prefixes -explicit-wire-types primitive.msg.encoded

# Decode raw message
echo
echo "* Decode without using any protobuf spec:"
cat primitive.msg.encoded | protoc --decode_raw

# Decode message
echo
echo "* Decode using the receiver protobuf spec (different than the primitive spec):"
cat primitive.msg.encoded | protoc --decode=primitive.Receiver receiver.proto
