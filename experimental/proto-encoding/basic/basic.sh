#!/bin/bash

# Encode message
echo "* Encode the following protobuf message:"
cat basic.msg
cat basic.msg | protoc --encode=basic.Greet basic.proto > basic.msg.encoded

# Print encoded message
echo
echo "* Encoded message in Wire format:"
cat basic.msg.encoded
echo
echo
echo "* Encoded message in Hexadecimal format:"
hexdump basic.msg.encoded
echo
echo "* Encoded message in Protoscope format:"
protoscope -explicit-length-prefixes -explicit-wire-types basic.msg.encoded

# Decode raw message
echo
echo "* Decode without using protobuf spec:"
cat basic.msg.encoded | protoc --decode_raw

# Decode message
echo
echo "* Decode using protobuf spec:"
cat basic.msg.encoded | protoc --decode=basic.Greet basic.proto
